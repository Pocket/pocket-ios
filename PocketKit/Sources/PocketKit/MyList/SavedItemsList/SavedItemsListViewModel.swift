import CoreData
import Sync
import Analytics
import Combine
import UIKit


class SavedItemsListViewModel: NSObject, ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    let selectionItem: SelectionItem = SelectionItem(title: "My List", image: .init(asset: .myList))

    @Published
    private var _snapshot = Snapshot()
    var snapshot: Published<Snapshot>.Publisher { $_snapshot }
    
    @Published
    var presentedAlert: PocketAlert?

    @Published
    var selectedItem: SelectedItem?

    @Published
    var sharedActivity: PocketActivity?
    
    var emptyState: EmptyStateViewModel? {
        let items = itemsController.fetchedObjects ?? []
        guard items.isEmpty else {
            return nil
        }
        
        return selectedFilters.contains(.favorites) ? FavoritesEmptyStateViewModel() : MyListEmptyStateViewModel()
    }

    private let source: Source
    private let tracker: Tracker
    private let itemsController: SavedItemsController
    private var subscriptions: [AnyCancellable] = []

    private var selectedFilters: Set<ItemsListFilter>
    private let availableFilters: [ItemsListFilter]

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
        self.selectedFilters = [.all]
        self.availableFilters = ItemsListFilter.allCases
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

        $selectedItem.sink { [weak self] itemSelected in
            guard itemSelected == nil else { return }
            self?._events.send(.selectionCleared)
        }.store(in: &subscriptions)

        source.events.sink { [weak self] event in
            self?.handle(syncEvent: event)
        }.store(in: &subscriptions)
    }

    func fetch() {
        let filters = selectedFilters.compactMap { filter -> NSPredicate? in
            switch filter {
            case .favorites:
                return NSPredicate(format: "isFavorite = true")
            case .all:
                return nil
            }
        }
        
        self.itemsController.predicate = Predicates.savedItems(filters: filters)

        try? self.itemsController.performFetch()
        self.itemsLoaded()
    }

    func refresh(_ completion: (() -> ())? = nil) {
        source.refresh(completion: completion)
        source.retryImmediately()
    }

    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return presenter(for: objectID)
    }

    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        bareItem(with: itemID).flatMap(ItemsListItemPresenter.init)
    }

    func filterButton(with filter: ItemsListFilter) -> TopicChipPresenter {
        return TopicChipPresenter(
            title: filter.rawValue,
            image: filter.image,
            isSelected: selectedFilters.contains(filter)
        )
    }

    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool {
        switch cell {
        case .filterButton:
            return true
        case .item(let objectID):
            return !(bareItem(with: objectID)?.isPending ?? true)
        case .offline, .emptyState, .placeholder:
            return false
        }
    }

    func selectCell(with cellID: ItemsListCell<ItemIdentifier>) {
        switch cellID {
        case .item(let objectID):
            select(item: objectID)
        case .filterButton(let filterID):
            apply(filter: filterID, from: cellID)
        case .offline, .emptyState, .placeholder:
            return
        }
    }

    func favoriteAction(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        if item.isFavorite {
            return .unfavorite { [weak self] _ in self?._unfavorite(item: item) }
        } else {
            return .favorite { [weak self] _ in self?._favorite(item: item) }
        }
    }

    private func _favorite(item: SavedItem) {
        track(item: item, identifier: .itemFavorite)
        source.favorite(item: item)
    }

    private func _unfavorite(item: SavedItem) {
        track(item: item, identifier: .itemUnfavorite)
        source.unfavorite(item: item)
    }

    func shareAction(for objectID: NSManagedObjectID) -> ItemAction? {
        guard let item = bareItem(with: objectID) else {
            return nil
        }

        return .share { [weak self] sender in self?._share(item: item, sender: sender) }
    }

    func _share(item: SavedItem, sender: Any?) {
        track(item: item, identifier: .itemShare)
        sharedActivity = PocketItemActivity(url: item.url, sender: sender)
    }

    func overflowActions(for objectID: NSManagedObjectID) -> [ItemAction] {
        guard let item = bareItem(with: objectID) else {
            return []
        }

        return [
            .archive { [weak self] _ in
                self?._archive(item: item)
            },
            .delete { [weak self] _ in
                self?.confirmDelete(item: item)
            }
        ]
    }

    func trailingSwipeActions(for objectID: NSManagedObjectID) -> [ItemContextualAction] {
        guard let item = bareItem(with: objectID) else {
            return []
        }

        return [
            .archive { [weak self] completion in
                self?._archive(item: item)
                completion(true)
            }
        ]
    }

    private func _archive(item: SavedItem) {
        track(item: item, identifier: .itemArchive)
        source.archive(item: item)
    }

    private func confirmDelete(item: SavedItem) {
        presentedAlert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: "No", style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                    self?._delete(item: item)
                }
            ],
            preferredAction: nil
        )
    }

    private func _delete(item: SavedItem) {
        track(item: item, identifier: .itemDelete)
        presentedAlert = nil
        source.delete(item: item)
    }

    private func bareItem(with id: NSManagedObjectID) -> SavedItem? {
        source.object(id: id)
    }

    private func itemsLoaded() {
        _snapshot = buildSnapshot()
    }

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> {
        var snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> = .init()
        let sections: [ItemsListSection] = [.filters]
        snapshot.appendSections(sections)

        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let itemCellIDs: [ItemsListCell<ItemIdentifier>]


        switch source.initialDownloadState.value {
        case .unknown, .completed:
            itemCellIDs = itemsController
                .fetchedObjects?
                .map { .item($0.objectID) } ?? []
        case .started:
            itemCellIDs = (0..<4).map { .placeholder($0) }
        case .paginating(let totalCount):
            itemCellIDs = (0..<totalCount).compactMap { index in
                guard let fetchedObjects = itemsController.fetchedObjects,
                      fetchedObjects.count > index else {
                    return .placeholder(index)
                      }

                return .item(fetchedObjects[index].objectID)
            }
        }
        
        guard !itemCellIDs.isEmpty else {
            snapshot.appendSections([.emptyState])
            snapshot.appendItems([ItemsListCell<ItemIdentifier>.emptyState], toSection: .emptyState)
            return snapshot
        }
        
        snapshot.appendSections([.items])
        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    func willDisplay(_ cell: ItemsListCell<NSManagedObjectID>) {
        if case .item = cell {
            withSavedItem(from: cell) { item in
                self.trackImpression(of: item)
            }
        }
    }

    private func track(item: SavedItem, identifier: UIContext.Identifier) {
        guard let url = item.bestURL, let indexPath = itemsController.indexPath(forObject: item) else {
            return
        }

        var contexts: [Context] = [
            UIContext.myList.item(index: UIIndex(indexPath.item)),
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
        ]

        if selectedFilters.contains(.favorites) {
            contexts.insert(UIContext.myList.favorites, at: 0)
        }

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }

    private func trackImpression(of item: SavedItem) {
        guard let url = item.bestURL, let indexPath = self.itemsController.indexPath(forObject: item) else {
            return
        }

        var contexts: [Context] = [
            UIContext.myList.item(index: UIIndex(indexPath.item)),
            ContentContext(url: url)
        ]

        if selectedFilters.contains(.favorites) {
            contexts.insert(UIContext.myList.favorites, at: 0)
        }

        let event = ImpressionEvent(component: .card, requirement: .instant)
        self.tracker.track(event: event, contexts)
    }

    private func withSavedItem(from cell: ItemsListCell<ItemIdentifier>, handler: ((SavedItem) -> Void)?) {
        guard case .item(let identifier) = cell, let item = bareItem(with: identifier) else {
            return
        }

        handler?(item)
    }
}

extension SavedItemsListViewModel {
    private func select(item itemID: ItemIdentifier) {
        guard let item = bareItem(with: itemID) else {
            return
        }

        if let item = item.item, item.shouldOpenInWebView {
            selectedItem = .webView(item.bestURL)
        } else {
            let selectedReadable = bareItem(with: itemID).flatMap {
                SavedItemViewModel(
                    item: $0,
                    source: source,
                    tracker: tracker.childTracker(hosting: .articleView.screen)
                )
            }
            selectedItem = .readable(selectedReadable)
        }
    }

    private func apply(filter: ItemsListFilter, from cell: ItemsListCell<ItemIdentifier>) {
        handleFilterSelection(with: filter)
        
        fetch()
        
        var snapshot = buildSnapshot()
        if snapshot.sectionIdentifiers.contains(.emptyState) {
            snapshot.reloadSections([.emptyState])
        }
        
        let cells = snapshot.itemIdentifiers(inSection: .filters)
        snapshot.reloadItems(cells)
        _snapshot = snapshot
    }
    
    private func handleFilterSelection(with filter: ItemsListFilter) {
        if filter == .all {
            selectedFilters.removeAll()
            selectedFilters.insert(.all)
        } else if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
            selectedFilters.remove(.all)
        }
        
        if selectedFilters.isEmpty {
            selectedFilters.insert(.all)
        }
    }
}

extension SavedItemsListViewModel: SavedItemsControllerDelegate {
    func controller(
        _ controller: SavedItemsController,
        didChange savedItem: SavedItem,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard .update == type else {
            return
        }

        var snapshot = buildSnapshot()
        snapshot.reloadItems([ItemsListCell<ItemIdentifier>.item(savedItem.objectID)])
        _snapshot = snapshot
    }

    func controllerDidChangeContent(_ controller: SavedItemsController) {
        itemsLoaded()
    }
}

// MARK: - handling sync events
extension SavedItemsListViewModel {
    private func handle(syncEvent: SyncEvent) {
        switch syncEvent {
        case .error, .loadedArchivePage:
            break
        case .savedItemCreated:
            fetch()
        case .savedItemsUpdated(let updatedSavedItems):
            try? itemsController.performFetch()
            updatedSavedItems.forEach {
                source.refresh($0, mergeChanges: true)
            }
            var snapshot = buildSnapshot()
            snapshot.reloadItems(updatedSavedItems.map { .item($0.objectID) })
            _snapshot = snapshot
        }
    }
}

// MARK: - Prefetching data
extension SavedItemsListViewModel {
    func prefetch(itemsAt: [IndexPath]) {
        // no op, prefetching is only needed in archive
    }
}
