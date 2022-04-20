import Foundation
import Sync
import Textile


private extension Style {
    static let sectionHeader: Style = .header.sansSerif.h7
}

struct SlateHeaderPresenter {
    private let slate: Slate

    init(slate: Slate) {
        self.slate = slate
    }

    var attributedHeaderText: NSAttributedString {
        NSAttributedString(string: slate.name ?? "", style: .sectionHeader)
    }
}
