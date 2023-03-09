import Foundation
import UIKit

public struct BannerViewModel {
    let prompt: String
    let buttonText: String
    let backgroundColor: UIColor
    let borderColor: UIColor
    let primaryAction: (URL?) -> Void
    let dismissAction: () -> Void

    var attributedText: NSAttributedString {
        return NSAttributedString(string: prompt, style: .main)
    }

    var attributedButtonText: AttributedString {
        return AttributedString(NSAttributedString(string: buttonText, style: .button))
    }

    public init(prompt: String, buttonText: String, backgroundColor: UIColor, borderColor: UIColor, primaryAction: @escaping (URL?) -> Void, dismissAction: @escaping () -> Void) {
        self.prompt = prompt
        self.buttonText = buttonText
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.primaryAction = primaryAction
        self.dismissAction = dismissAction
    }
}

private extension Style {
    static let main: Self = .header.sansSerif.p2.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }

    static let button: Self = .header.sansSerif.h8.with(color: .ui.white)
}
