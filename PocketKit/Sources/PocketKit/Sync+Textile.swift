// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Foundation
import UIKit


extension TextContent {
    func attributedString(baseStyle: Style) -> NSAttributedString {
        let attributedText: NSMutableAttributedString

        // TODO: Don't bother with markdown parsing
        // once backend is properly decoding HTML entities
        if let text = try? NSMutableAttributedString(markdown: text) {
            attributedText = text
            attributedText.addAttributes(
                baseStyle.textAttributes,
                range: NSRange(location: 0, length: attributedText.length)
            )
        } else {
            attributedText = NSMutableAttributedString(
                string: text,
                attributes: baseStyle.textAttributes
            )
        }

        applyModifiers(to: attributedText, baseStyle)
        return attributedText
    }

    private func applyModifiers(to attributedText: NSMutableAttributedString, _ baseStyle: Style) {
        guard let modifiers = modifiers else {
            return
        }

        for modifier in modifiers {
            guard let attrs = modifier.textAttributes(extending: baseStyle),
                  var range = modifier.range else {
                      return
                  }

            // Protect against out of bounds issues when applying new attributes.
            // Because decoding HTML entities sometimes changes the length of the string
            if range.location + range.length > attributedText.length {
                range.length = attributedText.length - range.location
            }
            
            guard let _ = Range(range, in: attributedText.string) else {
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

extension Header {
    var style: Style {
        switch level {
        case 1: return .header.serif.h1
        case 2: return .header.serif.h2
        case 3: return .header.serif.h3
        case 4: return .header.serif.h4
        case 5: return .header.serif.h5
        case 6: return .header.serif.h6
        default: return .header.serif.h1
        }
    }
}
