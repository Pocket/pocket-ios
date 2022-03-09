import CoreData
import Sync
import Analytics
import Combine
import UIKit


class SavedItemsListViewModel: NSObject, ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    let selectionItem: SelectionItem = SelectionItem(title: "My List", image: .init(asset: .myList))

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var selectedReadable: SavedItemViewModel?

    @Published
    var sharedActivity: PocketActivity?

    private let source: Source
    private let tracker: Tracker
    private let itemsController: SavedItemsController
    private var subscriptions: [AnyCancellable] = []

    private var selectedFilters: Set<ItemsListFilter>
    private let availableFilters: [ItemsListFilter]

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
        self.selectedFilters = []
        self.availableFilters = ItemsListFilter.allCases
        self.itemsController = source.makeItemsController()

        super.init()

        itemsController.delegate = self

        $selectedReadable.sink { [weak self] readable in
            guard readable == nil else { return }
            self?._events.send(.selectionCleared)
        }.store(in: &subscriptions)
    }

    func fetch() {
        var predicates: [NSPredicate] = []

        for filter in selectedFilters {
            switch filter {
            case .favorites:
                predicates.append(NSPredicate(format: "isFavorite = true", true))
            }
        }

        self.itemsController.predicate = Predicates.savedItems(filters: predicates)

        try? self.itemsController.performFetch()
        self.itemsLoaded()
    }

    func refresh(_ completion: (() -> ())? = nil) {
        source.refresh(completion: completion)
    }

    func item(with cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let objectID) = cellID else {
            return nil
        }

        return item(with: objectID)
    }

    func item(with itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        bareItem(with: itemID).flatMap(ItemsListItemPresenter.init)
    }

    func filterButton(with filterID: ItemsListFilter) -> TopicChipPresenter {
        TopicChipPresenter(
            title: filterID.rawValue,
            isSelected: selectedFilters.contains(filterID)
        )
    }

    func selectCell(with cellID: ItemsListCell<ItemIdentifier>) {
        switch cellID {
        case .item(let objectID):
            select(item: objectID)
        case .filterButton(let filterID):
            apply(filter: filterID, from: cellID)
        case .offline, .nextPage:
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

    func overflowActions(for objectID: NSManagedObjectID) -> [ItemAction]? {
        guard let item = bareItem(with: objectID) else {
            return nil
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

    func trailingSwipeActions(for objectID: NSManagedObjectID) -> [UIContextualAction] {
        guard let item = bareItem(with: objectID) else {
            return []
        }

        let archiveAction = UIContextualAction(style: .normal, title: "Archive") { [weak self] _, _, completion in
            self?._archive(item: item)
            completion(true)
        }
        archiveAction.backgroundColor = UIColor(.ui.lapis1)

        return [archiveAction]
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
        send(snapshot: buildSnapshot())
    }

    private func buildSnapshot() -> NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> {
        var snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>> = .init()

        let sections: [ItemsListSection] = [.filters, .items]
        snapshot.appendSections(sections)

        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        guard let itemCellIDs = itemsController.fetchedObjects?.map({ ItemsListCell<ItemIdentifier>.item($0.objectID) }) else {
            return snapshot
        }

        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    private func send(snapshot: NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>) {
        _events.send(.snapshot(snapshot))
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

        if let isArticle = item.item?.isArticle, isArticle == false
            || item.item?.hasImage == .isImage
            || item.item?.hasVideo == .isVideo {
            presentedWebReaderURL = item.bestURL
        } else {
            selectedReadable = bareItem(with: itemID).flatMap {
                SavedItemViewModel(
                    item: $0,
                    source: source,
                    tracker: tracker.childTracker(hosting: .articleView.screen)
                )
            }
        }
    }

    private func apply(filter: ItemsListFilter, from cell: ItemsListCell<ItemIdentifier>) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }

        var snapshot = buildSnapshot()
        snapshot.reloadItems([cell])
        send(snapshot: snapshot)

        fetch()
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
        send(snapshot: snapshot)
    }

    func controllerDidChangeContent(_ controller: SavedItemsController) {
        itemsLoaded()
    }
}
