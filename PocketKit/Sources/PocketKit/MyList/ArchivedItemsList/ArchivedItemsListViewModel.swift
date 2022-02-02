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

    private var selectedFilters: Set<ItemsListFilter> = .init()
    private let availableFilters: [ItemsListFilter] = ItemsListFilter.allCases

    init(source: Source, mainViewModel: MainViewModel, tracker: Tracker) {
        self.source = source
        self.mainViewModel = mainViewModel
        self.tracker = tracker
        self.events = .init()
    }

    func fetch() async throws {
        let favorited = selectedFilters.contains(.favorites)
        archivedItems = try await source.fetchArchivedItems(isFavorite: favorited)

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
        switch cell {
        case .filterButton(let filter):
            apply(filter: filter, from: cell)
        case .item(let itemID):
            select(item: itemID)
        }
    }

    func shareAction(for: String) -> ItemAction? {
        return nil
    }

    func favoriteAction(for: String) -> ItemAction? {
        return nil
    }

    func overflowActions(for: String) -> [ItemAction]? {
        return nil
    }

    func trailingSwipeActions(for objectID: String) -> [UIContextualAction] {
        return []
    }

    func trackImpression(_ cell: ItemsListCell<String>) {

    }
}

extension ArchivedItemsListViewModel {
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
    
    private func blankSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections(ItemsListSection.allCases)
        
        snapshot.appendItems(
            ItemsListFilter.allCases.map { ItemsListCell<ItemIdentifier>.filterButton($0) },
            toSection: .filters
        )
        
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
        events.send(.snapshot(snapshot))

        try? self.fetch()
    }
    
    private func select(item identifier: ItemIdentifier) {
        guard let archivedItem = archivedItemsByID[identifier] else {
            return
        }
        
        let viewModel = ArchivedItemViewModel(
            item: archivedItem,
            mainViewModel: mainViewModel,
            tracker: tracker.childTracker(hosting: .articleView.screen)
        )
        mainViewModel.selectedMyListReadableViewModel = viewModel
    }
}
