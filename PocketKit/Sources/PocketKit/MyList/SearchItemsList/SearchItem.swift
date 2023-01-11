import Foundation
import UIKit
import PocketGraph

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
        ItemAction.share { _ in print("Share button tapped!") }
    }

    var favoriteAction: ItemAction {
        ItemAction.favorite { _ in print("Favorite button tapped!") }
    }

    var overflowActions: [ItemAction] {
        [ItemAction.addTags { _ in print("Add tags button tapped!") }, ItemAction.archive { _ in print("Archive button tapped!") }, ItemAction.delete { _ in print("Delete button tapped!") }]
    }

    var trackOverflow: ItemAction {
        ItemAction(title: "", identifier: UIAction.Identifier(rawValue: ""), accessibilityIdentifier: "", image: nil, handler: {_ in
            print("Overflow button tapped!")
        })
    }
}
