import Foundation
import Textile
import UIKit
import SwiftUI


struct ItemAction {
    let title: String
    let identifier: UIAction.Identifier
    let accessibilityIdentifier: String
    let image: UIImage?
    let handler: ((Any?) -> ())?
}

extension ItemAction: Hashable {
    static func == (lhs: ItemAction, rhs: ItemAction) -> Bool {
        lhs.title == rhs.title
        && lhs.accessibilityIdentifier == rhs.accessibilityIdentifier
        && lhs.image == rhs.image
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(accessibilityIdentifier)
        hasher.combine(image)
    }
}

extension ItemAction {
    static func save(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Save",
            identifier: .saveItem,
            accessibilityIdentifier: "item-action-save",
            image: UIImage(asset: .save),
            handler: handler
        )
    }

    static func archive(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Archive",
            identifier: .archiveItem,
            accessibilityIdentifier: "item-action-archive",
            image: UIImage(asset: .archive),
            handler: handler
        )
    }

    static func delete(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Delete",
            identifier: .deleteItem,
            accessibilityIdentifier: "item-action-delete",
            // TODO: Use the pocket trash can icon here
            image: UIImage(systemName: "trash"),
            handler: handler
        )
    }

    static func moveToMyList(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Move to My List",
            identifier: .moveToMyListItem,
            accessibilityIdentifier: "item-action-move-to-my-list",
            image: UIImage(asset: .save),
            handler: handler
        )
    }

    static func favorite(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Favorite",
            identifier: .favoriteItem,
            accessibilityIdentifier: "item-action-favorite",
            image: UIImage(asset: .favorite)
                .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal),
            handler: handler
        )
    }

    static func unfavorite(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Unfavorite",
            // intentionally the same as `favorite()` since we want to replace
            identifier: .favoriteItem,
            accessibilityIdentifier: "item-action-favorite",
            image: UIImage(asset: .favoriteFilled)
                .withTintColor(UIColor(.branding.amber4), renderingMode: .alwaysOriginal),
            handler: handler
        )
    }

    static func share(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Share",
            identifier: .shareItem,
            accessibilityIdentifier: "item-action-share",
            image: UIImage(asset: .share),
            handler: handler
        )
    }
    
    static func displaySettings(_ handler: @escaping (Any?) -> ()) -> ItemAction {
        return ItemAction(
            title: "Display Settings",
            identifier: .displaySettings,
            accessibilityIdentifier: "item-action-display-settings",
            image: UIImage(systemName: "textformat.size"),
            handler: handler
        )
    }

    static func report(_ handler: @escaping (Any?) ->()) -> ItemAction {
        return ItemAction(
            title: "Report",
            identifier: .report,
            accessibilityIdentifier: "item-action-report",
            image: UIImage(asset: .alert),
            handler: handler
        )
    }
}

extension UIAction.Identifier {
    static let saveItem = UIAction.Identifier(rawValue: "save-item")
    static let archiveItem = UIAction.Identifier(rawValue: "archive-item")
    static let deleteItem = UIAction.Identifier(rawValue: "delete-item")
    static let moveToMyListItem = UIAction.Identifier(rawValue: "move-to-my-list-item")
    static let favoriteItem = UIAction.Identifier(rawValue: "favorite-item")
    static let shareItem = UIAction.Identifier(rawValue: "share-item")
    static let displaySettings = UIAction.Identifier(rawValue: "display-settings")
    static let report = UIAction.Identifier(rawValue: "report")
}

extension UIAction {
    convenience init?(_ readableAction: ItemAction?) {
        guard let action = readableAction else {
            return nil
        }

        self.init(title: action.title, image: action.image, identifier: action.identifier) { uiAction in
            action.handler?(uiAction.sender)
        }

        self.accessibilityIdentifier = action.accessibilityIdentifier
    }
}
