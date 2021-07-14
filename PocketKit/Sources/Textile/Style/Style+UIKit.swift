// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 1.0, *)
extension UIColor {
    convenience init?(_ colorAsset: ColorAsset) {
        self.init(
            named: colorAsset._name,
            in: .module,
            compatibleWith: nil
        )
    }
}

@available(iOS 1.0, *)
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

@available(iOS 1.0, *)
extension UIFontDescriptor {
    convenience init(_ descriptor: FontDescriptor) {
        var traits: [UIFontDescriptor.TraitKey: Any] = [
            .weight: descriptor.weight.flatMap(UIFont.Weight.init) ?? .regular,
        ]

        if let slant = descriptor.slant {
            switch slant {
            case .none:
                break
            case .italic:
                traits[.slant] = 1
            }
        }

        var fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
            .traits: traits,
        ]

        if let family = descriptor.family {
            fontAttributes[.family] = family.name
        }

        self.init(fontAttributes: fontAttributes)
    }
}

@available(iOS 1.0, *)
extension UIFont {
    convenience init(_ descriptor: FontDescriptor) {
        self.init(
            descriptor: UIFontDescriptor(descriptor),
            size: descriptor.size.flatMap(CGFloat.init) ?? UIFont.systemFontSize
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

@available(iOS 1.0, *)
public extension Style {
    var textAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFontMetrics.default.scaledFont(for: UIFont(fontDescriptor))
        ]

        if let color = UIColor(colorAsset) {
            attributes[.foregroundColor] = color
        }

        if let underline = NSUnderlineStyle(underlineStyle) {
            attributes[.underlineStyle] = underline.rawValue
        }

        if let strike = NSUnderlineStyle(strike) {
            attributes[.strikethroughStyle] = strike.rawValue
        }

        return attributes
    }
}

@available(iOS 15.0, *)
public extension Style {
    var attributes: AttributeContainer {
        var container = AttributeContainer()
        
        container.font = Font(fontDescriptor)
        
        container.foregroundColor = Color(colorAsset)
        
        if let underline = NSUnderlineStyle(underlineStyle) {
            container.underlineStyle = underline
        }
        
        if let strike = NSUnderlineStyle(strike) {
            container.strikethroughStyle = strike
        }
        
        return container
    }
}
