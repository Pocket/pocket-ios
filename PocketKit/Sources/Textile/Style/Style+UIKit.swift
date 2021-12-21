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

        let fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
            .traits: traits,
            .family: descriptor.family.name
        ]

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
    static func from(_ paragraphStyle: ParagraphStyle, fontDescriptor: FontDescriptor) -> NSParagraphStyle {
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
            let lineHeight = CGFloat(fontDescriptor.size.size) * multiplier
            style.minimumLineHeight = lineHeight
            style.maximumLineHeight = lineHeight
        case .none:
            break
        }

        return style
    }
}

public extension Style {
    var textAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .style: self,
            .font: UIFontMetrics.default.scaledFont(for: UIFont(fontDescriptor)),
            .paragraphStyle: NSParagraphStyle.from(paragraph, fontDescriptor: fontDescriptor),
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
}
