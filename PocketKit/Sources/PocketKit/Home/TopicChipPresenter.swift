import Foundation
import Sync
import Textile


private extension Style {
    static let title: Style = .header.sansSerif.h7
    static let toggled: Style = .title.with(color: .ui.white1)
}

struct TopicChipPresenter {
    private let title: String?
    let isSelected: Bool

    init(
        title: String?,
        isSelected: Bool = false
    ) {
        self.title = title
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
}

extension TopicChipPresenter: TopicChipCellModel {

}
