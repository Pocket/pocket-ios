import Foundation
import Sync
import Textile
import UIKit

private extension Style {
    static let title: Style = .header.sansSerif.h8
    static let toggled: Style = .title.with(color: .ui.teal1)
}

struct TopicChipPresenter {
    private let title: String?
    private let image: UIImage?
    let isSelected: Bool

    init(
        title: String?,
        image: UIImage?,
        isSelected: Bool = false
    ) {
        self.title = title
        self.image = image
        self.isSelected = isSelected
    }

    var attributedTitle: NSAttributedString? {
        let style: Style
        if isSelected {
            style = .toggled
        } else {
            style = .title
        }

        return NSAttributedString(string: title ?? "", style: style)
    }

    var iconImage: UIImage? {
        return image
    }
}

extension TopicChipPresenter: TopicChipCellModel {

}
