// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Down

public extension NSAttributedString {
    convenience init(string: String, style: Style) {
        self.init(string: string, attributes: style.textAttributes)
    }

    static func styled(markdown: String, styler: Styler) -> NSAttributedString? {
        let d = Down(markdownString: markdown)

        do {
            return try d.toAttributedString(styler: styler)
        } catch {
            print(error)
        }

        return nil
    }

    static func collectionStyler(bodyStyle: Style? = nil) -> Styler {
        var styling: FontStyling = BlancoOSFStyling()
        if let bodyStyle = bodyStyle {
            styling = styling.with(body: bodyStyle)
        }
        return CollectionStyler(styling: styling)
    }

    static func defaultStyler(
        with modifier: StylerModifier,
        bodyStyle: Style? = nil
    ) -> Styler {
        var styling = modifier.currentStyling
        if let bodyStyle = bodyStyle {
            styling = styling.with(body: bodyStyle)
        }

        return TextileStyler(
            styling: styling,
            modifier: modifier
        )
    }
}

public extension NSMutableAttributedString {
    func updateStyle(_ withStyle: (Style?) -> (Style)) {
        let range = NSRange(location: 0, length: length)
        enumerateAttribute(.style, in: range, options: []) { existingStyle, range, _ in
            let baseStyle = existingStyle as? Style
            addAttributes(withStyle(baseStyle).textAttributes, range: range)
        }
    }
}

public extension NSAttributedString.Key {
    static let style: Self = NSAttributedString.Key(rawValue: "textile.style")
}
