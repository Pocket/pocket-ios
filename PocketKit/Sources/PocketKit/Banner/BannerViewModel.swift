import Foundation
import Sync
import Textile
import UIKit

struct BannerViewModel {
    let prompt: String
    let backgroundColor: UIColor
    let borderColor: UIColor
    let primaryAction: ([NSItemProvider]) -> Void
    let dismissAction: () -> Void

    var attributedText: NSAttributedString {
        return NSAttributedString(string: prompt, style: .main)
    }
}

private extension Style {
    static let main: Self = .header.sansSerif.p2.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
}
