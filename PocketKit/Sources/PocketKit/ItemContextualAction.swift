import Foundation
import Textile
import UIKit

struct ItemContextualAction {
    let style: UIContextualAction.Style
    let title: String
    let image: UIImage?
    let backgroundColor: UIColor?
    let completion: (((Bool) -> Void) -> Void)?
}

extension ItemContextualAction {
    static func moveToSaves(_ completion: @escaping ((Bool) -> Void) -> Void) -> ItemContextualAction {
        ItemContextualAction(
            style: .destructive,
            title: "Move to Saves".localized(),
            image: UIImage(asset: .save),
            backgroundColor: UIColor(.ui.teal2),
            completion: completion
        )
    }

    static func archive(_ completion: @escaping ((Bool) -> Void) -> Void) -> ItemContextualAction {
        ItemContextualAction(
            style: .destructive,
            title: "Archive".localized(),
            image: UIImage(asset: .archive),
            backgroundColor: UIColor(.ui.teal2),
            completion: completion
        )
    }
}

extension UIContextualAction {
    convenience init?(_ itemContextualAction: ItemContextualAction?) {
        guard let action = itemContextualAction else {
            return nil
        }

        self.init(style: action.style, title: action.title) { _, _, completion in
            action.completion?(completion)
        }

        self.backgroundColor = action.backgroundColor
    }
}
