import Sync
import Combine
import UIKit


class ArchivedItemsListViewModel: ItemsListViewModel {
    typealias ItemIdentifier = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    var events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never>
    var presentedAlert: PocketAlert?
    let selectionItem: SelectionItem = SelectionItem(title: "Archive", image: .init(asset: .archive))

    private let source: Source
    private let mainViewModel: MainViewModel
    private var archivedItems: [String: ArchivedItem] = [:]

    @Published
    private var selectedFilters: Set<ItemsListFilter> = .init()
    private let availableFilters: [ItemsListFilter] = ItemsListFilter.allCases

    init(source: Source, mainViewModel: MainViewModel) {
        self.source = source
        self.mainViewModel = mainViewModel
        self.events = .init()
    }

    func fetch() async throws {
        let items = try await source.fetchArchivedItems()
        archivedItems = items.reduce(into: [:]) { partialResult, archivedItem in
            partialResult[archivedItem.remoteID] = archivedItem
        }

        let snapshot = buildSnapshot()
        events.send(.snapshot(snapshot))
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
        archivedItems[itemID].flatMap(ItemsListItemPresenter.init)
    }

    func fetch() throws {
        Task {
            try await self.fetch()
        }
    }

    func refresh(_ completion: (() -> ())?) {
        // TODO: Support pull to refresh
    }

    func selectCell(with cell: ItemsListCell<ItemIdentifier>) {
        guard case .item(let archivedItemID) = cell,
        let archivedItem = archivedItems[archivedItemID] else {
            return
        }
        
        let viewModel = ArchivedItemViewModel(item: archivedItem)
        mainViewModel.selectedMyListReadableViewModel = viewModel
    }

    func shareItem(with: ItemsListCell<ItemIdentifier>) {
        // TODO: share the item
    }

    private func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(ItemsListSection.allCases)

        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let itemCellIDs = archivedItems.keys.map { ItemsListCell<ItemIdentifier>.item($0) }
        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    func toggleFavorite(_ cell: ItemsListCell<String>) {

    }

    func archive(_ cell: ItemsListCell<String>) {

    }

    func delete(_ cell: ItemsListCell<String>) {

    }

    func trackImpression(_ cell: ItemsListCell<String>) {

    }
}
