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
    var selectedReadable: SavedItemViewModel?

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var presentedWebReaderURL: URL?

    private let source: Source
    private let tracker: Tracker

    private let networkMonitor: NetworkPathMonitor
    private var isNetworkAvailable: Bool {
        networkMonitor.currentNetworkPath.status == .satisfied
    }

    private let itemsController: SavedItemsController
    private var archivedItemsByID: [NSManagedObjectID: SavedItem] = [:]

    private var selectedFilters: Set<ItemsListFilter> = .init()
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
        self.itemsController = source.makeItemsController()

        itemsController.delegate = self
        itemsController.predicate = Predicates.archivedItems()
        networkMonitor.start(queue: .global())

        source.events.sink { [weak self] event in
            switch event {
            case .loadedArchivePage:
                self?.isFetching = false
            case .error:
                break
            }
        }.store(in: &subscriptions)

        $selectedReadable.sink { [weak self] readable in
            guard readable == nil else { return }
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

    func trailingSwipeActions(for objectID: ItemIdentifier) -> [UIContextualAction] {
        return []
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
            sendSnapshot(offlineSnapshot())
            return
        }

        fetchLocalItems()
    }

    func refresh(_ completion: (() -> ())?) {
        guard isNetworkAvailable else {
            completion?()
            sendSnapshot(offlineSnapshot())
            return
        }

        source.refresh(completion: completion)
        if itemsController.fetchedObjects == nil {
            fetchLocalItems()
        } else {
            sendSnapshot()
        }
    }

    private func fetchLocalItems() {
        let filters = selectedFilters.map { filter -> NSPredicate in
            switch filter {
            case .favorites:
                return NSPredicate(format: "isFavorite = true")
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

        sendSnapshot()
    }
}

// MARK: - Getting items for presentation
extension ArchivedItemsListViewModel {
    func filterButton(with id: ItemsListFilter) -> TopicChipPresenter {
        TopicChipPresenter(
            title: id.rawValue,
            isSelected: selectedFilters.contains(id)
        )
    }

    func item(with cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter? {
        guard case .item(let archivedItemID) = cellID else {
            return nil
        }

        return item(with: archivedItemID)
    }

    func item(with itemID: ItemIdentifier) -> ItemsListItemPresenter? {
        archivedItemsByID[itemID].flatMap(ItemsListItemPresenter.init)
    }
}

// MARK: - Deleting an item
extension ArchivedItemsListViewModel {
    func overflowActions(for itemID: ItemIdentifier) -> [ItemAction]? {
        guard let item = archivedItemsByID[itemID] else {
            return nil
        }

        return [
            .reAdd { [weak self] _ in self?.unarchive(item: item) },
            .delete { [weak self] _ in self?.confirmDelete(item: item) }
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

// MARK: - Re-adding items
extension ArchivedItemsListViewModel {
    func unarchive(item: SavedItem) {
        track(item: item, identifier: .itemSave)
        source.unarchive(item: item)
    }
}

// MARK: - Selecting cells
extension ArchivedItemsListViewModel {
    func selectCell(with cell: ItemsListCell<ItemIdentifier>) {
        switch cell {
        case .filterButton(let filter):
            apply(filter: filter, from: cell)
        case .item(let itemID):
            select(item: itemID)
        case .offline, .nextPage:
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
            presentedWebReaderURL = item.bestURL
        } else {
            selectedReadable = SavedItemViewModel(
                item: item,
                source: source,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )
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
        sendSnapshot(snapshot)

        fetchLocalItems()
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

    private func sendSnapshot(_ snapshot: Snapshot? = nil) {
        _events.send(.snapshot(snapshot ?? buildSnapshot()))
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
        sendSnapshot(snapshot(reloadingItem: aSavedItem.objectID))
    }

    func controllerDidChangeContent(_ controller: SavedItemsController) {
        updateItems()
    }
}
