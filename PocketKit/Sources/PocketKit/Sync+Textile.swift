// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Foundation


extension TextContent {
    func attributedString(baseStyle: Style) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: baseStyle.textAttributes
        )

        applyModifiers(to: attributedText, baseStyle)
        return attributedText
    }

    private func applyModifiers(to attributedText: NSMutableAttributedString, _ baseStyle: Style) {
        guard let modifiers = modifiers else {
            return
        }

        for modifier in modifiers {
            guard let attrs = modifier.textAttributes(extending: baseStyle),
                  let range = modifier.range else {
                return
            }

            attributedText.addAttributes(attrs, range: range)
        }
    }
}

extension InlineModifier {
    func textAttributes(extending baseStyle: Style) -> [NSAttributedString.Key: Any]? {
        switch self {
        case .link(let link):
            return link.textAttributes(baseStyle: baseStyle)
        case .style(let style):
            return style.extend(baseStyle)?.textAttributes
        case .unsupported:
            return nil
        }
    }

    var range: NSRange? {
        switch self {
        case .link(let link):
            return NSRange(location: link.start, length: link.length)
        case .style(let style):
            return NSRange(location: style.start, length: style.length)
        case .unsupported:
            return nil
        }
    }
}

extension InlineLink {
    func textAttributes(baseStyle: Style) -> [NSAttributedString.Key: Any] {
        var textAttributes = baseStyle
            .with(underlineStyle: .single)
            .textAttributes

        textAttributes[.link] = address

        return textAttributes
    }
}

extension InlineStyle {
    func extend(_ baseStyle: Textile.Style) -> Textile.Style? {
        switch style {
        case .big:
            return baseStyle.with(size: .h7)
        case .bold, .strong:
            return baseStyle.with(weight: .bold)
        case .italic:
            return baseStyle.with(slant: .italic)
        case .small:
            return baseStyle.with(size: .p4)
        case .strike:
            return baseStyle.with(strike: .strikethrough)
        case .unsupported:
            return nil
        }
    }
}
