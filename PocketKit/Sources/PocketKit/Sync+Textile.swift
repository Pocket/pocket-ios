// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Foundation


extension TextContent {
    func attributedString(baseStyle: Style) -> AttributedString? {
        do {
            var string = try AttributedString(markdown: text)
            string.setAttributes(baseStyle.attributes)
            
            guard let modifiers = modifiers else {
                return string
            }
            
            for modifier in modifiers {
                guard let attributes = modifier.attributes(extending: baseStyle),
                      let modifierRange = modifier.range,
                      let range = Range(modifierRange, in: string) else {
                          continue
                }
                
                string[range].mergeAttributes(attributes)
            }
            
            return string
        } catch {
            return nil
        }
    }
}

extension InlineModifier {    
    func attributes(extending baseStyle: Style) -> AttributeContainer? {
        switch self {
        case .link(let link):
            return link.attributes(baseStyle: baseStyle)
        case .style(let style):
            return style.extend(baseStyle)?.attributes
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
    func attributes(baseStyle: Style) -> AttributeContainer {
        var container = baseStyle
            .with(underlineStyle: .single)
            .attributes

        container.link = address

        return container
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
