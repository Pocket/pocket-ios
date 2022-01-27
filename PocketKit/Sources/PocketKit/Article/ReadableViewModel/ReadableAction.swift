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
}
