import Sync
import Combine
import UIKit
import Analytics
import Network


class ArchivedItemsListViewModel: ItemsListViewModel {
    typealias ItemIdentifier = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    private let _events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> = .init()
    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { _events.eraseToAnyPublisher() }

    let selectionItem: SelectionItem = SelectionItem(title: "Archive", image: .init(asset: .archive))

    @Published
    var selectedReadable: ArchivedItemViewModel?

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedAlert: PocketAlert?

    private let source: Source
    private let tracker: Tracker

    private let networkMonitor: NetworkPathMonitor
    private var isNetworkAvailable: Bool {
        networkMonitor.currentNetworkPath.status == .satisfied
    }

    private var archivedItemsByID: [String: ArchivedItem] = [:]
    private var archivedItems: [ArchivedItem] = [] {
        didSet {
            archivedItemsByID = archivedItems.reduce(into: [:]) { dict, archivedItem in
                dict[archivedItem.remoteID] = archivedItem
            }
        }
    }

    private var selectedFilters: Set<ItemsListFilter> = .init()
    private let availableFilters: [ItemsListFilter] = ItemsListFilter.allCases

    init(
        source: Source,
        tracker: Tracker,
        networkMonitor: NetworkPathMonitor = NWPathMonitor()
    ) {
        self.source = source
        self.tracker = tracker
        self.networkMonitor = networkMonitor

        networkMonitor.start(queue: .global())
//        self.main.$selectedMyListReadableViewModel.sink { _ in
//            // TODO: Handle deselection here
//        }.store(in: &subscriptions)
    }

    private func doFetch() async throws {
        if !isNetworkAvailable {
            _events.send(.snapshot(offlineSnapshot()))
        } else {
            _events.send(.snapshot(blankSnapshot()))

            let favorited = selectedFilters.contains(.favorites)
            archivedItems = try await source.fetchArchivedItems(isFavorite: favorited)

            let snapshot = buildSnapshot()
            _events.send(.snapshot(snapshot))
        }
    }

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

    func item(with itemID: String) -> ItemsListItemPresenter? {
        archivedItemsByID[itemID].flatMap(ItemsListItemPresenter.init)
    }

    func fetch() {
        Task {
            try await self.doFetch()
        }
    }

    func refresh(_ completion: (() -> ())?) {
        // TODO: Support pull to refresh
    }

    func selectCell(with cell: ItemsListCell<ItemIdentifier>) {
        switch cell {
        case .filterButton(let filter):
            apply(filter: filter, from: cell)
        case .item(let itemID):
            select(item: itemID)
        case .offline:
            return
        }
    }

    func shareAction(for itemID: String) -> ItemAction? {
        archivedItemsByID[itemID].flatMap { $0.bestURL }.flatMap { url in
            return .share { [weak self] sender in
                self?.sharedActivity = PocketItemActivity(url: url, sender: sender)
            }
        }
    }

    func favoriteAction(for itemID: String) -> ItemAction? {
        archivedItemsByID[itemID].flatMap { _ in
            return .favorite { _ in
                // TODO: Favorite the archived item
            }
        }
    }

    func overflowActions(for itemID: String) -> [ItemAction]? {
        return archivedItemsByID[itemID].flatMap { archivedItem in
            return [
                .delete { [weak self] _ in
                    self?.confirmDelete(item: archivedItem)
                }
            ]
        }
    }

    func trailingSwipeActions(for objectID: String) -> [UIContextualAction] {
        return []
    }

    func trackImpression(_ cell: ItemsListCell<String>) {
        // TODO: analytics for archived items
    }

    private func confirmDelete(item: ArchivedItem) {
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

    private func delete(item: ArchivedItem) {
        Task {
            try? await source.delete(item: item)

            guard let index = archivedItems.firstIndex(of: item) else {
                return
            }

            archivedItems.remove(at: index)
            _events.send(.snapshot(buildSnapshot()))
        }

        archivedItems.remove(at: index)
        _events.send(.snapshot(buildSnapshot()))
    }
}

extension ArchivedItemsListViewModel {
    private func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        let sections: [ItemsListSection] = [.filters, .items]
        snapshot.appendSections(sections)

        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let itemCellIDs = archivedItems.map { ItemsListCell<ItemIdentifier>.item($0.remoteID) }
        snapshot.appendItems(itemCellIDs, toSection: .items)
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

    private func apply(filter: ItemsListFilter, from cell: ItemsListCell<ItemIdentifier>) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }

        var snapshot = blankSnapshot()
        snapshot.reloadItems([cell])
        _events.send(.snapshot(snapshot))

        fetch()
    }

    private func select(item identifier: ItemIdentifier) {
        selectedReadable = archivedItemsByID[identifier].flatMap {
            ArchivedItemViewModel(
                item: $0,
                tracker: tracker.childTracker(hosting: .articleView.screen)
            )
        }
    }
}
