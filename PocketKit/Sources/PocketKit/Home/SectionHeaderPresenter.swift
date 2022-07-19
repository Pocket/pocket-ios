import Foundation
import Sync
import Textile


private extension Style {
    static let sectionHeader: Style = .header.sansSerif.h6.with(weight: .semibold)
}

struct SectionHeaderPresenter {
    private let slate: Slate?
    private let name: String?
    private let buttonTitle: String?

    init(slate: Slate) {
        self.slate = slate
        self.name = slate.name
        self.buttonTitle = "See All"
    }
    
    init(name: String, buttonTitle: String) {
        self.slate = nil
        self.name = name
        self.buttonTitle = buttonTitle
    }

    var attributedHeaderText: NSAttributedString {
        NSAttributedString(string: name ?? "", style: .sectionHeader)
    }
    
    var buttonHeaderText: String {
        buttonTitle ?? ""
    }
}
