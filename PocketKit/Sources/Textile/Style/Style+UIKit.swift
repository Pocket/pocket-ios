// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SwiftUI
import Down

extension UIColor {
    public convenience init(_ colorAsset: ColorAsset) {
        self.init(
            named: colorAsset._name,
            in: .module,
            compatibleWith: nil
        )!
    }
}

extension UIFont.Weight {
    init(_ weight: FontDescriptor.Weight) {
        switch weight {
        case .bold:
            self = .bold
        case .medium:
            self = .medium
        case .regular:
            self = .regular
        case .semibold:
            self = .semibold
        }
    }
}

extension UIFontDescriptor {
    convenience init(_ descriptor: FontDescriptor) {
        var traits: [UIFontDescriptor.TraitKey: Any] = [
            .weight: UIFont.Weight(descriptor.weight)
        ]

        switch descriptor.slant {
        case .none:
            break
        case .italic:
            traits[.slant] = 1
        }

        var fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
            .traits: traits,
            .family: descriptor.familyName
        ]
        if let fontName = descriptor.fontName {
            fontAttributes[.name] = fontName
        }

        self.init(fontAttributes: fontAttributes)
    }
}

extension UIFont {
    convenience init(_ descriptor: FontDescriptor) {
        self.init(
            descriptor: UIFontDescriptor(descriptor),
            size: CGFloat(descriptor.size)
        )
    }
}

extension NSUnderlineStyle {
    init?(_ underlineStyle: UnderlineStyle) {
        switch underlineStyle {
        case .none:
            return nil
        case .single:
            self = .single
        }
    }

    init?(_ strike: Strike) {
        switch strike {
        case .none:
            return nil
        case .strikethrough:
            self = .single
        }
    }
}

extension NSTextAlignment {
    init(_ textAlignment: TextAlignment) {
        switch textAlignment {
        case .left:
            self = .left
        case .right:
            self = .right
        case .center:
            self = .center
        case .justified:
            self = .justified
        }
    }
}

extension NSLineBreakMode {
    init?(_ lineBreakMode: LineBreakMode) {
        switch lineBreakMode {
        case .byTruncatingTail:
            self = .byTruncatingTail
        case .none:
            return nil
        }
    }
}

extension NSParagraphStyle {
    static func from(_ paragraphStyle: ParagraphStyle) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment(paragraphStyle.alignment)

        if let lineBreakMode = NSLineBreakMode(paragraphStyle.lineBreakMode) {
            style.lineBreakMode = lineBreakMode
        }

        if let lineSpacing = paragraphStyle.lineSpacing {
            style.lineSpacing = lineSpacing
        }

        switch paragraphStyle.lineHeight {
        case .explicit(let lineHeight):
            style.minimumLineHeight = lineHeight
            style.maximumLineHeight = lineHeight
        case .multiplier(let multiplier):
            style.lineHeightMultiple = multiplier
        case .none:
            break
        }

        return style
    }
}

public extension Style {
    var textAttributes: [NSAttributedString.Key: Any] {
        var font = UIFontMetrics.default.scaledFont(for: UIFont(fontDescriptor))
        if let maxScaleSize = maxScaleSize {
            font = UIFontMetrics.default.scaledFont(for: UIFont(fontDescriptor), maximumPointSize: maxScaleSize)
        }
        var attributes: [NSAttributedString.Key: Any] = [
            .style: self,
            .font: font,
            .paragraphStyle: NSParagraphStyle.from(paragraph),
            .foregroundColor: UIColor(colorAsset),
        ]

        if let underline = NSUnderlineStyle(underlineStyle) {
            attributes[.underlineStyle] = underline.rawValue
        }

        if let strike = NSUnderlineStyle(strike) {
            attributes[.strikethroughStyle] = strike.rawValue
        }

        if let backgroundColor = backgroundColorAsset {
            attributes[.backgroundColor] = UIColor(backgroundColor)
        }

        switch paragraph.verticalAlignment {
        case .center:
            guard let lineHeight = paragraph.lineHeight else {
                break
            }

            // Thinking of a line of text as a container, NSAttributedStrings by default render their text
            // against the bottom of the container. CSS's "line-height" property aligns the center of text
            // to the center of the container. We can mimic this behavior by offsetting the baseline by
            // a fraction of the difference between the font's line height and the requested line height.
            let font = attributes[.font] as! UIFont
            let styleLineHeight: CGFloat
            switch lineHeight {
            case .explicit(let value):
                styleLineHeight = value
            case .multiplier(let value):
                styleLineHeight = font.lineHeight * value
            }

            attributes[.baselineOffset] = (styleLineHeight - font.lineHeight) / 4
        default:
            break
        }

        return attributes
    }
}

public extension Style {
    var attributes: AttributeContainer {
        return AttributeContainer(textAttributes)
    }
}

public extension UIImage {
    convenience init(asset: ImageAsset) {
        self.init(named: asset.name, in: .module, with: nil)!
    }

    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
