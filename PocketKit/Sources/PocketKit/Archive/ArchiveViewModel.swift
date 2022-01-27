import Sync
import Combine
import UIKit


class ArchiveViewModel: ItemsListViewModel {
    typealias ItemIdentifier = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemListSection, ItemListCell<ItemIdentifier>>

    var events: PassthroughSubject<ItemListEvent<ItemIdentifier>, Never>
    var presentedAlert: PocketAlert?
    let selectionItem: SelectionItem = SelectionItem(title: "Archive", image: .init(asset: .archive))

    private let source: Source
    private var archivedItems: [String: ArchivedItem] = [:]

    @Published
    private var selectedFilters: Set<ItemListFilter> = .init()
    private let availableFilters: [ItemListFilter] = ItemListFilter.allCases

    init(source: Source) {
        self.source = source
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

    func filterButton(with id: ItemListFilter) -> TopicChipPresenter {
        TopicChipPresenter(
            title: id.rawValue,
            isSelected: selectedFilters.contains(id)
        )
    }

    func item(with cellID: ItemListCell<ItemIdentifier>) -> MyListItemPresenter? {
        guard case .item(let archivedItemID) = cellID else {
            return nil
        }

        return item(with: archivedItemID)
    }

    func item(with itemID: String) -> MyListItemPresenter? {
        archivedItems[itemID].flatMap(MyListItemPresenter.init)
    }

    func fetch() throws {
        Task {
            try await self.fetch()
        }
    }

    func refresh(_ completion: (() -> ())?) {
        // TODO: Support pull to refresh
    }

    func selectCell(with: ItemListCell<ItemIdentifier>) {
        // TODO: show the item in reader
    }

    func shareItem(with: ItemListCell<ItemIdentifier>) {
        // TODO: share the item
    }

    private func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(ItemListSection.allCases)

        snapshot.appendItems(
            ItemListFilter.allCases.map { ItemListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )

        let itemCellIDs = archivedItems.keys.map { ItemListCell<ItemIdentifier>.item($0) }
        snapshot.appendItems(itemCellIDs, toSection: .items)
        return snapshot
    }

    func toggleFavorite(_ cell: ItemListCell<String>) {

    }

    func archive(_ cell: ItemListCell<String>) {

    }

    func delete(_ cell: ItemListCell<String>) {

    }

    func trackImpression(_ cell: ItemListCell<String>) {

    }
}
