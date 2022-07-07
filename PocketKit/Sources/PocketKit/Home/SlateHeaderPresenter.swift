import Foundation
import Sync
import Textile


private extension Style {
    static let sectionHeader: Style = .header.sansSerif.h8
}

struct SlateHeaderPresenter {
    private let slate: Slate?
    private let name: String?

    init(slate: Slate) {
        self.slate = slate
        self.name = slate.name
    }
    
    init(name: String) {
        self.slate = nil
        self.name = name
    }

    var attributedHeaderText: NSAttributedString {
        NSAttributedString(string: name ?? "", style: .sectionHeader)
    }
}
