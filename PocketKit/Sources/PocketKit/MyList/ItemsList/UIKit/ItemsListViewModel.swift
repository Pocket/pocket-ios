// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import UIKit
import Sync
import Localization

enum SelectedItem {
    case readable(SavedItemViewModel?)
    case webView(SavedItemViewModel?)
    case collection(CollectionViewModel?)

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
        case .webView, .collection:
            break
        }
    }
}

enum ItemsListSection: Int, CaseIterable {
    case filters
    case tags
    case items
    case emptyState
    case offline
}

enum ItemsListCell<ItemIdentifier: Hashable>: Hashable {
    case filterButton(ItemsListFilter)
    case tag(String)
    case item(ItemIdentifier)
    case emptyState
    case offline
    case placeholder(Int)
}

enum ItemsListFilter: String, Hashable, CaseIterable {
    case all = "All"
    case listen = "Listen"
    case tagged = "Tagged"
    case favorites = "Favorites"
    case sortAndFilter = "Sort/Filter"

    var image: UIImage? {
        switch self {
        case .all:
            return nil
        case .listen:
            return UIImage(asset: .listen)
        case .tagged:
            return UIImage(asset: .tag)
        case .favorites:
            return UIImage(asset: .favorite)
        case .sortAndFilter:
            return UIImage(asset: .sortFilter)
        }
    }

    var localized: String {
        switch self {
        case .all:
            return Localization.Itemlist.Filter.all
        case .tagged:
            return Localization.Itemlist.Filter.tagged
        case .favorites:
            return Localization.Itemlist.Filter.favorites
        case .sortAndFilter:
            return Localization.Itemlist.Filter.sortFilter
        case .listen:
            return Localization.Carousel.listen
        }
    }
}

enum ItemsListEvent<ItemIdentifier: Hashable> {
    case selectionCleared
    case networkStatusUpdated
}

protocol ItemsListViewModelDelegate: AnyObject {
    func viewModel(_ itemsListViewModel: any ItemsListViewModel, didRequestListen: ListenConfiguration)
}

protocol ItemsListViewModel: AnyObject {
    associatedtype ItemIdentifier: Hashable
    typealias Snapshot = NSDiffableDataSourceSnapshot<ItemsListSection, ItemsListCell<ItemIdentifier>>

    var delegate: ItemsListViewModelDelegate? { get set }

    var events: AnyPublisher<ItemsListEvent<ItemIdentifier>, Never> { get }
    var selectionItem: SelectionItem { get }
    var emptyState: EmptyStateViewModel? { get }
    var snapshot: Published<Snapshot>.Publisher { get }
    var initialDownloadState: Published<InitialDownloadState>.Publisher { get }

    func fetch()
    func refresh(_ completion: (() -> Void)?)

    func preview(for cell: ItemsListCell<ItemIdentifier>) -> (ReadableViewModel, Bool)?
    func presenter(for cellID: ItemsListCell<ItemIdentifier>) -> ItemsListItemPresenter?
    func presenter(for itemID: ItemIdentifier) -> ItemsListItemPresenter?
    func filterButton(with id: ItemsListFilter) -> TopicChipPresenter
    func tagModel(with name: String) -> SelectedTagChipModel
    func shouldSelectCell(with cell: ItemsListCell<ItemIdentifier>) -> Bool
    func selectCell(with: ItemsListCell<ItemIdentifier>, sender: Any?)
    func beginBulkEdit()

    func filterByTagAction() -> UIAction?
    func trackOverflow(for objectID: ItemIdentifier) -> UIAction?
    func swiftUITrackOverflow(for objectID: ItemIdentifier) -> ItemAction?
    func shareAction(for objectID: ItemIdentifier) -> ItemAction?
    func favoriteAction(for objectID: ItemIdentifier) -> ItemAction?
    func overflowActions(for objectID: ItemIdentifier) -> [ItemAction]
    func trailingSwipeActions(for objectID: ItemIdentifier) -> [ItemContextualAction]

    func willDisplay(_ cell: ItemsListCell<ItemIdentifier>)
    func prefetch(itemsAt: [IndexPath])

    func reloadSnapshot(for identifiers: [ItemsListCell<ItemIdentifier>])
}
