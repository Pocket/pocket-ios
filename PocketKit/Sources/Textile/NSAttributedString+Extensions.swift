// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Down
import UIKit

public extension NSAttributedString {
    convenience init(string: String, style: Style) {
        self.init(string: string, attributes: style.textAttributes)
    }

    static func styled(markdown: String, styler: Styler) -> NSAttributedString? {
        let renderer = Down(markdownString: markdown)

        do {
            return try renderer.toAttributedString(styler: styler)
        } catch {
            print(error)
        }

        return nil
    }

    func highlighted() -> NSAttributedString {
        let highlightableString = self.string
        guard highlightableString.contains("pkt_tag_annotation>") else {
            return self
        }
        let scanner = Scanner(string: highlightableString)

        var highlightableRanges = [Range<String.Index>]()
        var indexStack = [String.Index]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString("pkt_tag_annotation>") != nil else {
                continue
            }
            let beforeIndex = max(highlightableString.index(before: scanner.currentIndex), highlightableString.startIndex)
            let character = String(highlightableString[beforeIndex])
            if character == "<" {
                indexStack.append(scanner.currentIndex)
            }
            if character == "/" {
                let tagIndex = highlightableString.index(before: beforeIndex)
                if let upperBound = indexStack.popLast() {
                    let range = Range<String.Index>(uncheckedBounds: (upperBound, tagIndex))
                    highlightableRanges.append(range)
                }
            }
            if !scanner.isAtEnd {
                scanner.currentIndex = highlightableString.index(after: scanner.currentIndex)
            }
        }
        let mutable = NSMutableAttributedString(attributedString: self)
        highlightableRanges.forEach {
            let nsRange = NSRange($0, in: highlightableString)
            mutable.addAttribute(.backgroundColor, value: UIColor.yellow, range: nsRange)
            mutable.addAttribute(.foregroundColor, value: UIColor.black, range: nsRange)
        }
        mutable.mutableString.replaceOccurrences(of: "<pkt_tag_annotation>", with: "", range: NSRange(location: 0, length: mutable.mutableString.length))
        mutable.mutableString.replaceOccurrences(of: "</pkt_tag_annotation>", with: "", range: NSRange(location: 0, length: mutable.mutableString.length))
        return mutable
    }

    static func collectionStyler(bodyStyle: Style? = nil) -> Styler {
        var styling: FontStyling = GenericFontStyling(family: .blanco)
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
    static let imageIconSize = CGSize(width: 16, height: 16)

    func updateStyle(_ withStyle: (Style?) -> (Style)) {
        let range = NSRange(location: 0, length: length)
        enumerateAttribute(.style, in: range, options: []) { existingStyle, range, _ in
            let baseStyle = existingStyle as? Style
            addAttributes(withStyle(baseStyle).textAttributes, range: range)
        }
    }

    func addSyndicatedIndicator(with style: Style) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        let image = UIImage(asset: .syndicatedIcon)
            .resized(to: NSMutableAttributedString.imageIconSize)
            .withTintColor(UIColor(style.colorAsset), renderingMode: .alwaysOriginal)

        imageAttachment.bounds = CGRect(x: 0, y: calculateLineHeight(for: image), width: image.size.width, height: image.size.height)
        imageAttachment.image = image

        let paddingAttributedString = NSAttributedString(string: " ")
        self.append(paddingAttributedString)
        self.append(NSAttributedString(attachment: imageAttachment))
        return self
    }

    private func calculateLineHeight(for image: UIImage) -> CGFloat {
        var imageLineHeight: CGFloat = 0
        if let font = self.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            /// See image to explain calculation here https://stackoverflow.com/questions/26105803/center-nstextattachment-image-next-to-single-line-uilabel
            imageLineHeight = (font.capHeight - image.size.height) / 2
        }
        return imageLineHeight
    }
}

public extension NSAttributedString.Key {
    static let style: Self = NSAttributedString.Key(rawValue: "textile.style")
}
