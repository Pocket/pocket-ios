import Foundation
import Sync
import Textile
import UIKit

struct BannerViewModel {
    let prompt: String
    let clipboardURL: String?
    var buttonText: String? = "Save"
    let backgroundColor: UIColor
    let borderColor: UIColor
    let primaryAction: () -> Void
    let dismissAction: () -> Void

    var attributedText: NSAttributedString {
        return NSAttributedString(string: prompt, style: .main)
    }

    var attributedDetailText: NSAttributedString {
        return NSAttributedString(string: clipboardURL ?? "", style: .detail)
    }

    var attributedButtonText: NSAttributedString {
        return NSAttributedString(string: buttonText ?? "", style: .button)
    }
}

private extension Style {
    static let main: Self = .header.sansSerif.p2.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
    static let detail: Self = .header.sansSerif.p4.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 16)
    static let button: Self = .header.sansSerif.h8.with(color: .ui.white)
}
