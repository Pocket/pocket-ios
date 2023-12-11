// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Down

public class TextileStyler: Styler {
    private let styling: FontStyling
    private let modifier: StylerModifier

    public init(
        styling: FontStyling,
        modifier: StylerModifier
    ) {
        self.styling = styling
        self.modifier = modifier
    }

    public func style(document str: NSMutableAttributedString) {
    }

    public func style(blockQuote str: NSMutableAttributedString, nestDepth: Int) {
    }

    public func style(list str: NSMutableAttributedString, nestDepth: Int) {
    }

    public func style(listItemPrefix str: NSMutableAttributedString) {
    }

    public func style(item str: NSMutableAttributedString, prefixLength: Int) {
    }

    public func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {
    }

    public func style(htmlBlock str: NSMutableAttributedString) {
    }

    public func style(customBlock str: NSMutableAttributedString) {
    }

    public func style(paragraph str: NSMutableAttributedString) {
    }

    public func style(heading str: NSMutableAttributedString, level: Int) {
        var headingStyle: Style
        switch level {
        case 1: headingStyle = styling.h1
        case 2: headingStyle = styling.h2
        case 3: headingStyle = styling.h3
        case 4: headingStyle = styling.h4
        case 5: headingStyle = styling.h5
        case 6: headingStyle = styling.h6
        default: headingStyle = styling.bolding(style: styling.body)
        }

        str.updateStyle { existingStyle in
            guard let existingStyle = existingStyle else {
                return headingStyle.modified(by: modifier)
            }

            headingStyle = headingStyle.with(slant: existingStyle.fontDescriptor.slant)

            if existingStyle.fontDescriptor.family == styling.monospace.fontDescriptor.family {
                headingStyle = headingStyle
                    .with(family: existingStyle.fontDescriptor.family)
                    .with(backgroundColor: .ui.grey6)
            }

            return headingStyle.modified(by: modifier)
        }
    }

    public func style(thematicBreak str: NSMutableAttributedString) {
    }

    public func style(text str: NSMutableAttributedString) {
        str.updateStyle { _ in
            styling.body.modified(by: modifier)
        }
    }

    public func style(softBreak str: NSMutableAttributedString) {
    }

    public func style(lineBreak str: NSMutableAttributedString) {
    }

    public func style(code str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            styling.monospace.with(backgroundColor: .ui.grey6).modified(by: modifier)
        }
    }

    public func style(htmlInline str: NSMutableAttributedString) {
    }

    public func style(customInline str: NSMutableAttributedString) {
    }

    public func style(emphasis str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            (existingStyle ?? styling.body).with(slant: .italic).modified(by: modifier)
        }
    }

    public func style(strong str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            let style = existingStyle ?? styling.body
            return styling.bolding(style: style).modified(by: modifier)
        }
    }

    public func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        str.updateStyle { existingStyle in
            (existingStyle ?? styling.body).with(underlineStyle: .single).modified(by: modifier)
        }

        if let urlString = url, let url = URL(string: urlString) {
            let range = NSRange(location: 0, length: str.length)
            str.addAttribute(.link, value: url, range: range)
        }
    }

    public func style(image str: NSMutableAttributedString, title: String?, url: String?) {
    }
}
