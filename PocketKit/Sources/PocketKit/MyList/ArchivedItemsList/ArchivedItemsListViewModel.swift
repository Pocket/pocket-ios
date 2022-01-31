import Sync
import Combine
import UIKit
import Analytics


class ArchivedItemsListViewModel: ItemsListViewModel {
    typealias ItemIdentifier = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    var events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never>
    var presentedAlert: PocketAlert?
    let selectionItem: SelectionItem = SelectionItem(title: "Archive", image: .init(asset: .archive))

    private let source: Source
    private let mainViewModel: MainViewModel
    private let tracker: Tracker

    private var archivedItems: [ArchivedItem] = [] {
        didSet {
            archivedItemsByID = archivedItems.reduce(into: [:]) { dict, archivedItem in
                dict[archivedItem.remoteID] = archivedItem
            }
        }
    }
    private var archivedItemsByID: [String: ArchivedItem] = [:]

    @Published
    private var selectedFilters: Set<ItemsListFilter> = .init()
    private let availableFilters: [ItemsListFilter] = ItemsListFilter.allCases

    init(source: Source, mainViewModel: MainViewModel, tracker: Tracker) {
        self.source = source
        self.mainViewModel = mainViewModel
        self.tracker = tracker
        self.events = .init()
    }

    func fetch() async throws {
        archivedItems = try await source.fetchArchivedItems()

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
        archivedItemsByID[itemID].flatMap(ItemsListItemPresenter.init)
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
        let archivedItem = archivedItemsByID[archivedItemID] else {
            return
        }
        
        let viewModel = ArchivedItemViewModel(
            item: archivedItem,
            mainViewModel: mainViewModel,
            tracker: tracker.childTracker(hosting: .articleView.screen)
        )
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

        let itemCellIDs = archivedItems.map { ItemsListCell<ItemIdentifier>.item($0.remoteID) }
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
