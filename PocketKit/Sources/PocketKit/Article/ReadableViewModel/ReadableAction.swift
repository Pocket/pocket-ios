import Foundation
import Textile
import UIKit


struct ReadableAction {
    let title: String
    let accessibilityIdentifier: String
    let image: UIImage?
    let handler: (() -> ())?
}

extension ReadableAction {
    static func save(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Save",
            accessibilityIdentifier: "item-action-menu-save",
            image: UIImage(asset: .save),
            handler: handler
        )
    }

    static func archive(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Archive",
            accessibilityIdentifier: "item-action-menu-archive",
            image: UIImage(systemName: "archivebox"),
            handler: handler
        )
    }

    static func delete(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Delete",
            accessibilityIdentifier: "item-action-menu-delete",
            image: UIImage(systemName: "trash"),
            handler: handler
        )
    }

    static func favorite(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Favorite",
            accessibilityIdentifier: "item-action-menu-favorite",
            image: UIImage(systemName: "star"),
            handler: handler
        )
    }

    static func unfavorite(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Unfavorite",
            accessibilityIdentifier: "item-action-menu-unfavorite",
            image: UIImage(systemName: "star.slash"),
            handler: handler
        )
    }
    
    static func displaySettings(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Display Settings",
            accessibilityIdentifier: "item-action-menu-display-settings",
            image: UIImage(systemName: "textformat.size"),
            handler: handler
        )
    }
    
    static func share(_ handler: @escaping () -> ()) -> ReadableAction {
        return ReadableAction(
            title: "Share",
            accessibilityIdentifier: "item-action-menu-share",
            image: UIImage(systemName: "square.and.arrow.up"),
            handler: handler
        )
    }
}
