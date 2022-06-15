import Combine
import UIKit

enum SelectedItem {
    case readable(SavedItemViewModel?)
    case webView(URL?)
    
    func clearPresentedWebReaderURL() {
        switch self {
        case .readable(let viewModel):
            viewModel?.presentedWebReaderURL = nil
        default:
            break
        }
    }
    
    func clearSharedActivity() {
        switch self {
        case .readable(let viewModel):
            viewModel?.sharedActivity = nil
        default:
            break
        }
    }
}

enum ItemsListSection: Int, CaseIterable {
    case filters
    case items
    case emptyState
    case offline
    case nextPage
}

enum ItemsListCell<ItemIdentifier: Hashable>: Hashable {
    case filterButton(ItemsListFilter)
    case item(ItemIdentifier)
    case emptyState(ItemsEmptyState)
    case offline
    case nextPage
}

enum ItemsEmptyState: String, Hashable, CaseIterable {
    case myList = "MyList"
    case archive = "Archive"
    case favorites = "Favorites"
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

    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter?
    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter?
    func filterButton(with id: ItemsListFilter) -> TopicChipPresenter
    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool
    func selectCell(with: ItemsListCell<ItemIdentifier>)

    func shareAction(for objectID: ItemIdentifier) -> ItemAction?
    func favoriteAction(for objectID: ItemIdentifier) -> ItemAction?
    func overflowActions(for objectID: ItemIdentifier) -> [ItemAction]
    func trailingSwipeActions(for objectID: ItemIdentifier) -> [ItemContextualAction]

    func willDisplay(_ cell: ItemsListCell<ItemIdentifier>)
}
