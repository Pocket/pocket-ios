// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Down

// Styles markdown for native collections
public class CollectionStyler: Styler {
    private let styling: FontStyling
    enum Constants {
        static let paragraphIndent: CGFloat = 20
    }

    public init(styling: FontStyling) {
        self.styling = styling
    }

    public func style(document str: NSMutableAttributedString) {
    }

    public func style(blockQuote str: NSMutableAttributedString, nestDepth: Int) {
        str.updateStyle { existingStyle in
            styling.body.with(color: .ui.grey4).with(slant: .italic)
        }

        // Modifies blockquote to be indented
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = Constants.paragraphIndent
        paragraphStyle.headIndent = Constants.paragraphIndent
        str.addAttributes([
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: str.length))
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
                return headingStyle
            }

            headingStyle = headingStyle.with(slant: existingStyle.fontDescriptor.slant)

            if existingStyle.fontDescriptor.family == styling.monospace.fontDescriptor.family {
                headingStyle = headingStyle
                    .with(family: existingStyle.fontDescriptor.family)
                    .with(backgroundColor: .ui.grey6)
            }

            return headingStyle
        }
    }

    public func style(thematicBreak str: NSMutableAttributedString) {
    }

    public func style(text str: NSMutableAttributedString) {
        str.updateStyle { _ in
            styling.body
        }
    }

    public func style(softBreak str: NSMutableAttributedString) {
    }

    public func style(lineBreak str: NSMutableAttributedString) {
    }

    public func style(code str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            styling.monospace.with(backgroundColor: .ui.grey6)
        }
    }

    public func style(htmlInline str: NSMutableAttributedString) {
    }

    public func style(customInline str: NSMutableAttributedString) {
    }

    public func style(emphasis str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            (existingStyle ?? styling.body).with(slant: .italic)
        }
    }

    public func style(strong str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            let style = existingStyle ?? styling.body
            return styling.bolding(style: style)
        }
    }

    public func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        str.updateStyle { existingStyle in
            (existingStyle ?? styling.body).with(underlineStyle: .single)
        }

        if let urlString = url, let url = URL(string: urlString) {
            let range = NSRange(location: 0, length: str.length)
            str.addAttribute(.link, value: url, range: range)
        }
    }

    public func style(image str: NSMutableAttributedString, title: String?, url: String?) {
    }
}
