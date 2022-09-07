import Combine
import UIKit

enum SelectedItem {
    case readable(SavedItemViewModel?)
    case webView(URL?)

    func clearPresentedWebReaderURL() {
        switch self {
        case .readable(let viewModel):
            viewModel?.clearPresentedWebReaderURL()
        default:
            break
        }
    }

    func clearSharedActivity() {
        switch self {
        case .readable(let viewModel):
            viewModel?.clearSharedActivity()
        default:
            break
        }
    }

    func clearIsPresentingReaderSettings() {
        switch self {
        case .readable(let readable):
            readable?.clearIsPresentingReaderSettings()
        case .webView:
            break
        }
    }
}

enum ItemsListSection: Int, CaseIterable {
    case filters
    case items
    case emptyState
    case offline
}

enum ItemsListCell<ItemIdentifier: Hashable>: Hashable {
    case filterButton(ItemsListFilter)
    case item(ItemIdentifier)
    case emptyState
    case offline
    case placeholder(Int)
}

enum ItemsListFilter: String, Hashable, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case sortAndFilter = "Sort/Filter"

    var image: UIImage? {
        switch self {
        case .all:
            return nil
        case .favorites:
            return UIImage(asset: .favorite)
        case .sortAndFilter:
            return UIImage(asset: .sortFilter)
        }
    }
}

enum ItemsListEvent<ItemIdentifier: Hashable> {
    case selectionCleared
}

protocol ItemsListViewModel: AnyObject {
    associatedtype ItemIdentifier: Hashable
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { get }
    var selectionItem: SelectionItem { get }
    var emptyState: EmptyStateViewModel? { get }
    var snapshot: Published<Snapshot>.Publisher { get }

    func fetch()
    func refresh(_ completion: (() -> Void)?)

    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter?
    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter?
    func filterButton(with id: ItemsListFilter) -> TopicChipPresenter
    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool
    func selectCell(with: ItemsListCell<ItemIdentifier>, sender: Any)

    func shareAction(for objectID: ItemIdentifier) -> ItemAction?
    func favoriteAction(for objectID: ItemIdentifier) -> ItemAction?
    func overflowActions(for objectID: ItemIdentifier) -> [ItemAction]
    func trailingSwipeActions(for objectID: ItemIdentifier) -> [ItemContextualAction]

    func willDisplay(_ cell: ItemsListCell<ItemIdentifier>)
    func prefetch(itemsAt: [IndexPath])
}
