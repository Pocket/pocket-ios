import Foundation
import Textile
import UIKit
import SwiftUI
import Localization

struct ItemAction {
    let title: String
    let identifier: UIAction.Identifier
    let accessibilityIdentifier: String
    let image: UIImage?
    let handler: ((Any?) -> Void)?
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
    static func save(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.save,
            identifier: .saveItem,
            accessibilityIdentifier: "item-action-save",
            image: UIImage(asset: .save),
            handler: { sender in
                Haptics.saveTap()
                handler(sender)
            }
        )
    }

    static func archive(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.archive,
            identifier: .archiveItem,
            accessibilityIdentifier: "item-action-archive",
            image: UIImage(asset: .archive),
            handler: { sender in
                Haptics.archiveTap()
                handler(sender)
            }
        )
    }

    static func delete(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.delete,
            identifier: .deleteItem,
            accessibilityIdentifier: "item-action-delete",
            image: UIImage(asset: .delete),
            handler: { sender in
                Haptics.deleteTap()
                handler(sender)
            }
        )
    }

    static func addTags(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.addTags,
            identifier: .addTagsItem,
            accessibilityIdentifier: "item-action-add-tags",
            image: UIImage(asset: .tag),
            handler: { sender in
                Haptics.addTagsTap()
                handler(sender)
            }
        )
    }

    static func moveToSaves(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.moveToSaves,
            identifier: .moveToSavesItem,
            accessibilityIdentifier: "item-action-move-to-saves",
            image: UIImage(asset: .save),
            handler: { sender in
                Haptics.moveToSavesTap()
                handler(sender)
            }
        )
    }

    static func favorite(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.favorite,
            identifier: .favoriteItem,
            accessibilityIdentifier: "item-action-favorite",
            image: UIImage(asset: .favorite)
                .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal),
            handler: { sender in
                Haptics.favoriteTap()
                handler(sender)
            }
        )
    }

    static func unfavorite(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.unfavorite,
            // intentionally the same as `favorite()` since we want to replace
            identifier: .favoriteItem,
            accessibilityIdentifier: "item-action-favorite",
            image: UIImage(asset: .favoriteFilled)
                .withTintColor(UIColor(.branding.amber4), renderingMode: .alwaysOriginal),
            handler: { sender in
                Haptics.unfavoriteTap()
                handler(sender)
            }
        )
    }

    static func share(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.share,
            identifier: .shareItem,
            accessibilityIdentifier: "item-action-share",
            image: UIImage(asset: .share),
            handler: { sender in
                Haptics.shareTap()
                handler(sender)
            }
        )
    }

    static func displaySettings(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.displaySettings,
            identifier: .displaySettings,
            accessibilityIdentifier: "item-action-display-settings",
            image: UIImage(systemName: "textformat.size"),
            handler: { sender in
                Haptics.displaySettingsTap()
                handler(sender)
            }
        )
    }

    static func report(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.report,
            identifier: .report,
            accessibilityIdentifier: "item-action-report",
            image: UIImage(asset: .alert),
            handler: { sender in
                Haptics.reportTap()
                handler(sender)
            }
        )
    }

    static func recommendationPrimary(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: "",
            identifier: .recommendationPrimary,
            accessibilityIdentifier: "item-action-recommendation-primary",
            image: nil,
            handler: { sender in
                Haptics.recomendationPrimaryTap()
                handler(sender)
            }
        )
    }

    static func copyLink(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.copyLink,
            identifier: .copyLink,
            accessibilityIdentifier: "item-action-copy-link",
            image: UIImage(systemName: "link"),
            handler: { sender in
                Haptics.copyLinkTap()
                handler(sender)
            }
        )
    }

    static func open(_ handler: @escaping (Any?) -> Void) -> ItemAction {
        return ItemAction(
            title: Localization.open,
            identifier: .open,
            accessibilityIdentifier: "item-action-open",
            image: UIImage(systemName: "safari"),
            handler: { sender in
                Haptics.openItemTap()
                handler(sender)
            }
        )
    }
}

extension UIAction.Identifier {
    static let saveItem = UIAction.Identifier(rawValue: "save-item")
    static let archiveItem = UIAction.Identifier(rawValue: "archive-item")
    static let deleteItem = UIAction.Identifier(rawValue: "delete-item")
    static let addTagsItem = UIAction.Identifier(rawValue: "add-tags-item")
    static let moveToSavesItem = UIAction.Identifier(rawValue: "move-to-saves-item")
    static let favoriteItem = UIAction.Identifier(rawValue: "favorite-item")
    static let shareItem = UIAction.Identifier(rawValue: "share-item")
    static let displaySettings = UIAction.Identifier(rawValue: "display-settings")
    static let report = UIAction.Identifier(rawValue: "report")
    static let recommendationPrimary = UIAction.Identifier(rawValue: "recommendation-primary")
    static let seeAllPrimary = UIAction.Identifier(rawValue: "see-all-primary")
    static let copyLink = UIAction.Identifier(rawValue: "copy-link")
    static let open = UIAction.Identifier(rawValue: "open")
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
