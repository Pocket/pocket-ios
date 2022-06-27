import Sync
import Combine
import UIKit
import Analytics
import Network
import CoreData


class ArchivedItemsListViewModel: ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    let selectionItem: SelectionItem = SelectionItem(title: "Archive", image: .init(asset: .archive))

    @Published
    private var _snapshot = Snapshot()
    var snapshot: Published<Snapshot>.Publisher { $_snapshot }
    
    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var selectedItem: SelectedItem?
    
    var emptyState: EmptyStateViewModel? {
        let items = itemsController.fetchedObjects ?? []
        guard items.isEmpty else {
            return nil
        }
        return selectedFilters.contains(.favorites) ? FavoritesEmptyStateViewModel() : ArchiveEmptyStateViewModel()
    }

    private let source: Source
    private let tracker: Tracker

    private let networkMonitor: NetworkPathMonitor
    private var isNetworkAvailable: Bool {
        networkMonitor.currentNetworkPath.status == .satisfied
    }

    private let itemsController: SavedItemsController
    private var archivedItemsByID: [NSManagedObjectID: SavedItem] = [:]

    private var selectedFilters: Set<ItemsListFilter> = .init([.all])
    private let availableFilters: [ItemsListFilter] = ItemsListFilter.allCases

    private var isFetching: Bool = false
    private var subscriptions: [AnyCancellable] = []

    init(
        source: Source,
        tracker: Tracker,
        networkMonitor: NetworkPathMonitor = NWPathMonitor()
    ) {
        self.source = source
        self.tracker = tracker
        self.networkMonitor = networkMonitor
        self.itemsController = source.makeArchivedItemsController()

        itemsController.delegate = self
        networkMonitor.start(queue: .global())

        source.events.sink { [weak self] event in
            switch event {
            case .loadedArchivePage:
                self?.isFetching = false
            case .error, .savedItemCreated, .savedItemsUpdated:
                break
            }
        }.store(in: &subscriptions)

        $selectedItem.sink { [weak self] itemSelected in
            guard itemSelected == nil else { return }
            self?._events.send(.selectionCleared)
        }.store(in: &subscriptions)
    }

    func shareAction(for itemID: ItemIdentifier) -> ItemAction? {
        guard let item = archivedItemsByID[itemID] else {
            return nil
        }

        return .share { [weak self] sender in self?.share(item: item, sender: sender) }
    }

    private func share(item: SavedItem, sender: Any?) {
        track(item: item, identifier: .itemShare)
        sharedActivity = PocketItemActivity(url: item.bestURL, sender: sender)
    }

    func willDisplay(_ cell: ItemsListCell<ItemIdentifier>) {
        if case .nextPage = cell, !isFetching, isNetworkAvailable {
            isFetching = true
            let cursor = itemsController.fetchedObjects?.last?.cursor
            let isFavorite: Bool? = selectedFilters.contains(.favorites) ? true : nil
            source.fetchArchivePage(cursor: cursor, isFavorite: isFavorite)
        } else if case .item(let identifier) = cell {
            guard let item = archivedItemsByID[identifier] else {
                return
            }

            trackImpression(of: item)
        }
    }
}

// MARK: - Fetching Items
extension ArchivedItemsListViewModel {
    func fetch() {
        guard isNetworkAvailable else {
            _snapshot = offlineSnapshot()
            return
        }

        fetchLocalItems()
    }

    func refresh(_ completion: (() -> ())?) {
        guard isNetworkAvailable else {
            completion?()
            _snapshot = offlineSnapshot()
            return
        }

        source.refresh(completion: completion)
        if itemsController.fetchedObjects == nil {
            fetchLocalItems()
        } else {
            _snapshot = buildSnapshot()
        }
    }

    private func fetchLocalItems() {
        let filters = selectedFilters.compactMap { filter -> NSPredicate? in
            switch filter {
            case .favorites:
                return NSPredicate(format: "isFavorite = true")
            case .all:
                return nil
            }
        }

        itemsController.predicate = Predicates.archivedItems(filters: filters)
        try? itemsController.performFetch()
        updateItems()
    }

    func updateItems() {
        archivedItemsByID = itemsController.fetchedObjects?.reduce(into: [:]) { dict, savedItem in
            dict[savedItem.objectID] = savedItem
        } ?? [:]

        _snapshot = buildSnapshot()
    }
}

// MARK: - Getting items for presentation
extension ArchivedItemsListViewModel {
    func filterButton(with filter: ItemsListFilter) -> TopicChipPresenter {
        TopicChipPresenter(
            title: filter.rawValue,
            image: filter.image,
            isSelected: selectedFilters.contains(filter)
        )
    }

    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let archivedItemID) = cellID else {
            return nil
        }

        return presenter(for: archivedItemID)
    }

    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        archivedItemsByID[itemID].flatMap(ItemsListItemPresenter.init)
    }
}

// MARK: - Deleting an item
extension ArchivedItemsListViewModel {
    func overflowActions(for itemID: ItemIdentifier) -> [ItemAction] {
        guard let item = archivedItemsByID[itemID] else {
            return []
        }

        return [
            .moveToMyList { [weak self] _ in self?.moveToMyList(item: item) },
            .delete { [weak self] _ in self?.confirmDelete(item: item) }
        ]
    }

    func trailingSwipeActions(for objectID: ItemIdentifier) -> [ItemContextualAction] {
        guard let item = archivedItemsByID[objectID] else {
            return []
        }

        return [
            .moveToMyList { [weak self] completion in
                self?.moveToMyList(item: item)
                completion(true)
            }
        ]
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
                    self?.presentedAlert = nil
                    self?.delete(item: item)
                }
            ],
            preferredAction: nil
        )
    }

    private func delete(item: SavedItem) {
        track(item: item, identifier: .itemDelete)
        source.delete(item: item)
    }
}

// MARK: - Favoriting/Unfavoriting an item
extension ArchivedItemsListViewModel {
    func favoriteAction(for itemID: ItemIdentifier) -> ItemAction? {
        guard let item = archivedItemsByID[itemID] else {
            return nil
        }

        if item.isFavorite {
            return .unfavorite { [weak self] _ in self?.unfavorite(item: item) }
        } else {
            return .favorite { [weak self] _ in self?.favorite(item: item) }
        }
    }

    private func favorite(item: SavedItem) {
        track(item: item, identifier: .itemFavorite)
        source.favorite(item: item)
    }

    private func unfavorite(item: SavedItem) {
        track(item: item, identifier: .itemUnfavorite)
        source.unfavorite(item: item)
    }
}

// MARK: - Move to My List
extension ArchivedItemsListViewModel {
    func moveToMyList(item: SavedItem) {
        track(item: item, identifier: .itemSave)
        source.unarchive(item: item)
    }
}

// MARK: - Selecting cells
extension ArchivedItemsListViewModel {
    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool {
        switch cell {
        case .filterButton: return true
        case .item(let objectID): return !(archivedItemsByID[objectID]?.isPending ?? true)
        case .emptyState: return false
        case .nextPage: return false
        case .offline: return false
        }
    }

    func selectCell(with cell: ItemsListCell<ItemIdentifier>) {
        switch cell {
        case .filterButton(let filter):
            apply(filter: filter, from: cell)
        case .item(let itemID):
            select(item: itemID)
        case .emptyState, .offline, .nextPage:
            return
        }
    }

    private func select(item identifier: ItemIdentifier) {
        guard let item = archivedItemsByID[identifier] else {
            return
        }

        if let isArticle = item.item?.isArticle, isArticle == false
            || item.item?.hasImage == .isImage
            || item.item?.hasVideo == .isVideo {
            selectedItem = .webView(item.bestURL)
        } else {
            selectedItem = .readable(
                SavedItemViewModel(
                    item: item,
                    source: source,
                    tracker: tracker.childTracker(hosting: .articleView.screen)
                )
            )
        }
    }

    private func apply(filter: ItemsListFilter, from cell: ItemsListCell<ItemIdentifier>) {
        handleFilterSelection(with: filter)

        fetchLocalItems()
        
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

// MARK: - Building and sending snapshots
extension ArchivedItemsListViewModel {
    private func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections([.filters, .items, .nextPage])
        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let itemCellIDs = itemsController.fetchedObjects?.map { ItemsListCell<ItemIdentifier>.item($0.objectID) } ?? []

        if itemCellIDs.isEmpty {
            snapshot.appendSections([.emptyState])
            snapshot.appendItems([ItemsListCell<ItemIdentifier>.emptyState], toSection: .emptyState)
        }

        snapshot.appendItems(itemCellIDs, toSection: .items)
        snapshot.appendItems([.nextPage], toSection: .nextPage)
        return snapshot
    }

    private func snapshot(reloadingItem itemID: ItemIdentifier) -> Snapshot {
        var snapshot = buildSnapshot()
        snapshot.reloadItems([.item(itemID)])

        return snapshot
    }

    private func blankSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        let sections: [ItemsListSection] = [.filters, .items]
        snapshot.appendSections(sections)

        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        return snapshot
    }

    private func offlineSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.offline])
        snapshot.appendItems([.offline], toSection: .offline)
        return snapshot
    }
}

// MARK: - Tracking

extension ArchivedItemsListViewModel {
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
}

extension ArchivedItemsListViewModel: SavedItemsControllerDelegate {
    func controller(_ controller: SavedItemsController, didChange aSavedItem: SavedItem, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard .update == type else { return }
        _snapshot = snapshot(reloadingItem: aSavedItem.objectID)
    }

    func controllerDidChangeContent(_ controller: SavedItemsController) {
        updateItems()
    }
}
