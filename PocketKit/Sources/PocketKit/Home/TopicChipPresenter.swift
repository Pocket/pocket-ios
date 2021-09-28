import Foundation
import Sync
import Textile


private extension Style {
    static let title: Style = .header.sansSerif.h7
}

struct TopicChipPresenter {
    private let slate: Slate

    init(slate: Slate) {
        self.slate = slate
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(slate.name ?? "", style: .title)
    }
}
