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

    private var archivedItemsByID: [String: (index: Int, item: ArchivedItem)] = [:]
    private var archivedItems: [ArchivedItem] = [] {
        didSet {
            archivedItemsByID = archivedItems.enumerated().reduce(into: [:]) { dict, enumeratedItem in
                dict[enumeratedItem.element.remoteID] = (
                    index: enumeratedItem.offset,
                    item: enumeratedItem.element
                )
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

    func shareAction(for itemID: String) -> ItemAction? {
        bareItem(with: itemID).flatMap { $0.bestURL }.flatMap { url in
            return .share { [weak self] sender in
                self?.sharedActivity = PocketItemActivity(url: url, sender: sender)
            }
        }
    }

    func trailingSwipeActions(for objectID: String) -> [UIContextualAction] {
        return []
    }

    func trackImpression(_ cell: ItemsListCell<String>) {
        // TODO: analytics for archived items
    }

    private func bareItem(with itemID: String) -> ArchivedItem? {
        archivedItemsByID[itemID]?.item
    }
}

// MARK: - Fetching Items
extension ArchivedItemsListViewModel {
    func fetch() {
        Task { try await self._fetch() }
    }

    func refresh(_ completion: (() -> ())?) {
        // TODO: Support pull to refresh
    }

    private func _fetch() async throws {
        if !isNetworkAvailable {
            sendSnapshot(offlineSnapshot())
        } else {
            sendSnapshot(blankSnapshot())

            let favorited = selectedFilters.contains(.favorites)
            archivedItems = try await source.fetchArchivedItems(isFavorite: favorited)
            sendSnapshot()
        }
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

    func item(with itemID: String) -> ItemsListItemPresenter? {
        bareItem(with: itemID).flatMap(ItemsListItemPresenter.init)
    }
}

// MARK: - Deleting an item
extension ArchivedItemsListViewModel {
    func overflowActions(for itemID: String) -> [ItemAction]? {
        return bareItem(with: itemID).flatMap { archivedItem in
            return [
                .delete { [weak self] _ in self?.confirmDelete(item: archivedItem) },
                .reAdd { [weak self] _ in self?.reAdd(item: archivedItem) }
            ]
        }
    }

    private func delete(item: ArchivedItem) {
        Task { await _delete(item: item) }
    }

    private func _delete(item: ArchivedItem) async {
        guard let index = archivedItemsByID[item.remoteID]?.index else {
            return
        }

        archivedItems.remove(at: index)
        sendSnapshot()

        do {
            try await source.delete(item: item)
        } catch {
            await presentGenericError()
            archivedItems.insert(item, at: index)
            sendSnapshot()
        }
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
}

// MARK: - Favoriting/Unfavoriting an item
extension ArchivedItemsListViewModel {
    func favoriteAction(for itemID: String) -> ItemAction? {
        bareItem(with: itemID).flatMap { archivedItem in
            if archivedItem.isFavorite {
                return .unfavorite { [weak self] _ in
                    self?.unfavorite(item: archivedItem)
                }
            } else {
                return .favorite { [weak self] _ in
                    self?.favorite(item: archivedItem)
                }
            }
        }
    }

    private func favorite(item: ArchivedItem) {
        Task { await setIsFavorite(true, on: item) }
    }

    private func unfavorite(item: ArchivedItem) {
        Task { await setIsFavorite(false, on: item) }
    }

    private func setIsFavorite(_ isFavorite: Bool, on item: ArchivedItem) async {
        guard let index = archivedItemsByID[item.remoteID]?.index else {
            return
        }

        archivedItems[index] = item.with(isFavorite: isFavorite)
        sendSnapshot(snapshot(reloadingItem: item.remoteID))

        do {
            if isFavorite {
                try await source.favorite(item: item)
            } else {
                try await source.unfavorite(item: item)
            }
        } catch {
            await presentGenericError()

            archivedItems[index] = item
            sendSnapshot(snapshot(reloadingItem: item.remoteID))
        }
    }
}

// MARK: - Re-adding items
extension ArchivedItemsListViewModel {
    func reAdd(item: ArchivedItem) {
        Task { await _reAdd(item: item) }
    }

    func _reAdd(item: ArchivedItem) async {
        guard let index = archivedItemsByID[item.remoteID]?.index else {
            return
        }

        archivedItems.remove(at: index)
        sendSnapshot()

        try? await source.reAdd(item: item)
        await source.refresh()
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
        case .offline:
            return
        }
    }

    private func select(item identifier: ItemIdentifier) {
        selectedReadable = archivedItemsByID[identifier].flatMap { $0.item }.flatMap {
            ArchivedItemViewModel(
                item: $0,
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

        var snapshot = blankSnapshot()
        snapshot.reloadItems([cell])
        sendSnapshot(snapshot)
        fetch()
    }
}

// MARK: - Presenting alerts
extension ArchivedItemsListViewModel {
    @MainActor
    private func present(alert: PocketAlert) {
        presentedAlert = alert
    }

    private func presentGenericError() async {
        await present(
            alert: PocketAlert(
                title: "Error",
                message: "Please try again later",
                preferredStyle: .alert,
                actions: [
                    UIAlertAction(
                        title: "Ok",
                        style: .default
                    ) { [weak self] _ in
                        self?.presentedAlert = nil
                    }
                ],
                preferredAction: nil
            )
        )
    }
}

// MARK: - Building and sending snapshots
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

    private func snapshot(reloadingItem itemID: String) -> Snapshot {
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
