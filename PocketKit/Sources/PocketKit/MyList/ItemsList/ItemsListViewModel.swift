import Combine
import UIKit


enum ItemsListSection: Int, CaseIterable {
    case filters
    case items
    case offline
    case nextPage
}

enum ItemsListCell<ItemIdentifier: Hashable>: Hashable {
    case filterButton(ItemsListFilter)
    case item(ItemIdentifier)
    case offline
    case nextPage
}

enum ItemsListFilter: String, Hashable, CaseIterable {
    case favorites = "Favorites"
}

enum ItemsListEvent<ItemIdentifier: Hashable> {
    case selectionCleared
    case snapshot(NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>)
}

protocol ItemsListViewModel: AnyObject {
    associatedtype ItemIdentifier: Hashable

    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { get }
    var selectionItem: SelectionItem { get }

    func fetch()
    func refresh(_ completion: (() -> ())?)

    func item(with cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter?
    func item(with itemID: ItemIdentifier) -> ItemsListItemPresenter?
    func filterButton(with id: ItemsListFilter) -> TopicChipPresenter
    func selectCell(with: ItemsListCell<ItemIdentifier>)

    func shareAction(for objectID: ItemIdentifier) -> ItemAction?
    func favoriteAction(for objectID: ItemIdentifier) -> ItemAction?
    func overflowActions(for objectID: ItemIdentifier) -> [ItemAction]?
    func trailingSwipeActions(for objectID: ItemIdentifier) -> [UIContextualAction]

    func willDisplay(_ cell: ItemsListCell<ItemIdentifier>)
}
