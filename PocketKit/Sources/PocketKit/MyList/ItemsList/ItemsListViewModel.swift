import Combine
import UIKit


enum ItemsListSection: Int, CaseIterable {
    case filters
    case items
}

enum ItemsListCell<ItemIdentifier: Hashable>: Hashable {
    case filterButton(ItemsListFilter)
    case item(ItemIdentifier)
}

enum ItemsListFilter: String, Hashable, CaseIterable {
    case favorites = "Favorites"
}

enum ItemsListEvent<ItemIdentifier: Hashable> {
    case deselectEverythingRenameMe
    case snapshot(NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>)
}

protocol ItemsListViewModel: AnyObject {
    associatedtype ItemIdentifier: Hashable

    var events: PassthroughSubject<ItemsListEvent<ItemIdentifier>, Never> { get }
    var presentedAlert: PocketAlert? { get set }
    var selectionItem: SelectionItem { get }

    func fetch() throws
    func refresh(_ completion: (() -> ())?)

    func item(with cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter?
    func item(with itemID: ItemIdentifier) -> ItemsListItemPresenter?
    func filterButton(with id: ItemsListFilter) -> TopicChipPresenter
    func selectCell(with: ItemsListCell<ItemIdentifier>)

    func shareAction(for objectID: ItemIdentifier) -> ItemAction?
    func favoriteAction(for objectID: ItemIdentifier) -> ItemAction?
    func overflowActions(for objectID: ItemIdentifier) -> [ItemAction]?
    func trailingSwipeActions(for objectID: ItemIdentifier) -> [UIContextualAction]

    func trackImpression(_ cell: ItemsListCell<ItemIdentifier>)
}
