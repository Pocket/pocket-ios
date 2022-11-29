import Foundation
import Sync
import Textile
import UIKit

struct BannerViewModel {
    let prompt: String
    let backgroundColor: UIColor
    let borderColor: UIColor
    let primaryAction: (URL?) -> Void
    let dismissAction: () -> Void

    var attributedText: NSAttributedString {
        return NSAttributedString(string: prompt, style: .main)
    }

    var attributedButtonText: AttributedString {
        return AttributedString(NSAttributedString(string: "Save".localized(), style: .button))
    }
}

private extension Style {
    static let main: Self = .header.sansSerif.p2.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }

    static let button: Self = .header.sansSerif.h8.with(color: .ui.white)
}
