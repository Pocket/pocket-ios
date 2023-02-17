import Foundation
import UIKit
import PocketGraph
import Sync

struct SearchItem {
    private let item: ItemsListItem
    private let itemPresenter: ItemsListItemPresenter

    init(item: ItemsListItem) {
        self.item = item
        self.itemPresenter = ItemsListItemPresenter(item: item)
    }

    var id: String? {
        item.id
    }

    var title: NSAttributedString {
        itemPresenter.attributedTitle
    }

    var detail: NSAttributedString {
        itemPresenter.attributedDetail
    }

    var tags: [NSAttributedString]? {
        itemPresenter.attributedTags
    }

    var tagCount: NSAttributedString? {
        itemPresenter.attributedTagCount
    }

    var thumbnailURL: URL? {
        itemPresenter.thumbnailURL
    }

    var shareAction: ItemAction {
        ItemAction.share { _ in Log.info("Share button tapped!") }
    }

    var favoriteAction: ItemAction {
        ItemAction.favorite { _ in Log.info("Favorite button tapped!") }
    }

    var overflowActions: [ItemAction] {
        [ItemAction.addTags { _ in Log.info("Add tags button tapped!") }, ItemAction.archive { _ in Log.info("Archive button tapped!") }, ItemAction.delete { _ in Log.info("Delete button tapped!") }]
    }

    var trackOverflow: ItemAction {
        ItemAction(title: "", identifier: UIAction.Identifier(rawValue: ""), accessibilityIdentifier: "", image: nil, handler: {_ in
            Log.info("Overflow button tapped!")
        })
    }

    var remoteItemReaderView: SavedItemReaderView? {
        item.remoteItemReaderView
    }
}
