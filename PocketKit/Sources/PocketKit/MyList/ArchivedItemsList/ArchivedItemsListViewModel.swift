import Sync
import Combine
import UIKit
import Analytics
import Network
import CoreData

class ArchivedItemsListViewModel: ItemsListViewModel {
    typealias ItemIdentifier = NSManagedObjectID
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    let selectionItem: SelectionItem = SelectionItem(title: "Archive", image: .init(asset: .archive))

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    @Published
    private var _snapshot = Snapshot()
    var snapshot: Published<Snapshot>.Publisher { $_snapshot }

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var presentedAddTags: AddTagsViewModel?

    @Published
    var selectedItem: SelectedItem?

    var emptyState: EmptyStateViewModel? {
        return selectedFilters.contains(.favorites) ? FavoritesEmptyStateViewModel() : ArchiveEmptyStateViewModel()
    }

    private let source: Source
    private let tracker: Tracker

    private let networkMonitor: NetworkPathMonitor
    private var lastPathStatus: NWPath.Status?
    private var isNetworkAvailable: Bool {
        networkMonitor.currentNetworkPath.status == .satisfied
    }

    private let archiveService: ArchiveService
    private var archivedItemsByID: [NSManagedObjectID: SavedItem] = [:]

    private var selectedFilters: Set<ItemsListFilter> = .init([.all])
    private let availableFilters: [ItemsListFilter] = ItemsListFilter.allCases

    private var isFetching: Bool = false
    private var isRefreshing: Bool = false
    private var subscriptions: [AnyCancellable] = []

    init(
        source: Source,
        tracker: Tracker,
        networkMonitor: NetworkPathMonitor = NWPathMonitor()
    ) {
        self.source = source
        self.tracker = tracker
        self.networkMonitor = networkMonitor
        self.archiveService = source.makeArchiveService()

        networkMonitor.start(queue: .global())

        source.events.sink { [weak self] event in
            switch event {
            case .loadedArchivePage:
                self?.isFetching = false
            case .error, .savedItemCreated, .savedItemsUpdated:
                break
            }
        }.store(in: &subscriptions)

        archiveService.results.sink { [weak self] results in
            self?.handleResults(results: results)
        }.store(in: &subscriptions)

        archiveService.itemUpdated.sink { [weak self] updatedItem in
            self?.handleUpdatedItem(updatedItem)
        }.store(in: &subscriptions)

        $selectedItem.sink { [weak self] itemSelected in
            guard itemSelected == nil else { return }
            self?._events.send(.selectionCleared)
        }.store(in: &subscriptions)
    }

    private func savedItem(_ itemID: ItemIdentifier) -> SavedItem? {
        return archiveService.object(id: itemID)
    }
}

// MARK: - Fetching Items
extension ArchivedItemsListViewModel {
    func fetch() {
        if isNetworkAvailable {
            refresh { }
        } else {
            _snapshot = offlineSnapshot()
        }

        observeNetworkChanges()
    }

    func refresh(_ completion: (() -> Void)?) {
        guard isNetworkAvailable else {
            _snapshot = offlineSnapshot()
            completion?()
            return
        }

        guard !isRefreshing else {
            return
        }

        isRefreshing = true
        archiveService.refresh { [weak self] in
            completion?()
            self?.isRefreshing = false
        }
    }

    func handleResults(results: [SavedItemResult]) {
        _snapshot = buildSnapshot(results: results)
    }

    func handleUpdatedItem(_ updatedItem: SavedItem) {
        if _snapshot.indexOfItem(.item(updatedItem.objectID)) != nil {
            _snapshot.reloadItems([.item(updatedItem.objectID)])
        }
    }

    private func observeNetworkChanges() {
        networkMonitor.updateHandler = { [weak self] path in
            self?.handleNetworkChange(path)
        }
    }

    private func handleNetworkChange(_ path: NetworkPath?) {
        let currentPathStatus = path?.status

        if lastPathStatus != currentPathStatus, currentPathStatus == .satisfied {
            refresh { }
        }

        lastPathStatus = currentPathStatus
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
        savedItem(itemID).flatMap(ItemsListItemPresenter.init)
    }
}

// MARK: - Item actions
extension ArchivedItemsListViewModel {
    func favoriteAction(for itemID: ItemIdentifier) -> ItemAction? {
        guard let item = savedItem(itemID) else {
            return nil
        }

        if item.isFavorite {
            return .unfavorite { [weak self] _ in self?.unfavorite(item: item) }
        } else {
            return .favorite { [weak self] _ in self?.favorite(item: item) }
        }
    }

    func shareAction(for itemID: ItemIdentifier) -> ItemAction? {
        guard let item = savedItem(itemID) else {
            return nil
        }

        return .share { [weak self] sender in self?.share(item: item, sender: sender) }
    }

    func overflowActions(for itemID: ItemIdentifier) -> [ItemAction] {
        guard let item = savedItem(itemID) else {
            return []
        }

        return [
            .addTags { [weak self] _ in self?.showAddTagsView(item: item) },
            .moveToMyList { [weak self] _ in self?.moveToMyList(item: item) },
            .delete { [weak self] _ in self?.confirmDelete(item: item) }
        ]
    }

    func trailingSwipeActions(for objectID: ItemIdentifier) -> [ItemContextualAction] {
        guard let item = savedItem(objectID) else {
            return []
        }

        return [
            .moveToMyList { [weak self] completion in
                self?.moveToMyList(item: item)
                completion(true)
            }
        ]
    }
}

// MARK: - Favorite/Unfavorite an item
extension ArchivedItemsListViewModel {
    private func favorite(item: SavedItem) {
        track(item: item, identifier: .itemFavorite)
        source.favorite(item: item)
    }

    private func unfavorite(item: SavedItem) {
        track(item: item, identifier: .itemUnfavorite)
        source.unfavorite(item: item)
    }
}

// MARK: - Move item to My List
extension ArchivedItemsListViewModel {
    func moveToMyList(item: SavedItem) {
        track(item: item, identifier: .itemSave)
        source.unarchive(item: item)
    }
}

// MARK: - Share an item
extension ArchivedItemsListViewModel {
    private func share(item: SavedItem, sender: Any?) {
        track(item: item, identifier: .itemShare)
        sharedActivity = PocketItemActivity(url: item.bestURL, sender: sender)
    }
}

// MARK: - Delete an item
extension ArchivedItemsListViewModel {
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

// MARK: - Add Tags to an item
extension ArchivedItemsListViewModel {
    private func showAddTagsView(item: SavedItem) {
        presentedAddTags = AddTagsViewModel(
            item: item,
            source: source,
            saveAction: { [weak self] in
                self?.archiveService.fetch()
            }
        )
    }
}

// MARK: - Cell selection
extension ArchivedItemsListViewModel {
    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool {
        switch cell {
        case .filterButton:
            return true
        case .item(let objectID):
            return !(savedItem(objectID)?.isPending ?? true)
        case .emptyState, .offline, .placeholder:
            return false
        }
    }

    func selectCell(with cell: ItemsListCell<ItemIdentifier>, sender: Any) {
        switch cell {
        case .filterButton(let filter):
            apply(filter: filter, from: cell)
        case .item(let itemID):
            select(item: itemID)
        case .emptyState, .offline, .placeholder:
            return
        }
    }

    private func select(item identifier: ItemIdentifier) {
        guard let item = savedItem(identifier) else {
            return
        }

        if let item = item.item, item.shouldOpenInWebView {
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

        archiveService.filters = selectedFilters.compactMap { filter in
            switch filter {
            case .all:
                return nil
            case .favorites:
                return .favorites
            case .sortAndFilter:
                return nil
            }
        }

        _snapshot.reloadSections([.filters])
    }

    private func handleFilterSelection(with filter: ItemsListFilter) {
        if filter == .all {
            selectedFilters = [.all]
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

// MARK: - Cell lifecycle
extension ArchivedItemsListViewModel {
    func willDisplay(_ cell: ItemsListCell<ItemIdentifier>) {
        guard case .item(let itemID) = cell,
              let item = savedItem(itemID) else {
            return
        }

        trackImpression(of: item)
    }

    func prefetch(itemsAt indexPaths: [IndexPath]) {
        archiveService.fetch(at: indexPaths.map(\.item))
    }
}

// MARK: - Tracking
extension ArchivedItemsListViewModel {
    private func trackImpression(of item: SavedItem) {
        guard let url = item.bestURL, let index = archiveService.index(of: item) else {
            return
        }

        var contexts: [Context] = [
            UIContext.myList.item(index: UIIndex(index)),
            ContentContext(url: url)
        ]

        if selectedFilters.contains(.favorites) {
            contexts.insert(UIContext.myList.favorites, at: 0)
        }

        let event = ImpressionEvent(component: .card, requirement: .instant)
        self.tracker.track(event: event, contexts)
    }

    private func track(item: SavedItem, identifier: UIContext.Identifier) {
        guard let url = item.bestURL, let index = archiveService.index(of: item) else {
            return
        }

        var contexts: [Context] = [
            UIContext.myList.item(index: UIIndex(index)),
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

// MARK: - Building and sending snapshots
extension ArchivedItemsListViewModel {
    private func buildSnapshot(results: [SavedItemResult]) -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections([.filters, .items])
        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let itemCellIDs: [ItemsListCell<ItemIdentifier>] = results.enumerated().map { (index, result) in
            switch result {
            case .loaded(let savedItem):
                return .item(savedItem.objectID)
            case .notLoaded:
                return .placeholder(index)
            }
        }

        if itemCellIDs.isEmpty {
            snapshot.appendSections([.emptyState])
            snapshot.appendItems([ItemsListCell<ItemIdentifier>.emptyState], toSection: .emptyState)
        }

        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    private func snapshot(results: [SavedItemResult], reloadingItem itemID: ItemIdentifier) -> Snapshot {
        var snapshot = buildSnapshot(results: results)
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

// MARK: - Clearing presented content
extension ArchivedItemsListViewModel {
    func clearSharedActivity() {
        sharedActivity = nil
        selectedItem?.clearSharedActivity()
    }

    func clearPresentedWebReaderURL() {
        switch selectedItem {
        case .readable(let readable):
            readable?.clearPresentedWebReaderURL()
        case .webView:
            selectedItem = nil
        case .none:
            break
        }
    }

    func clearIsPresentingReaderSettings() {
        selectedItem?.clearIsPresentingReaderSettings()
    }

    func clearSelectedItem() {
        selectedItem = nil
    }
}
