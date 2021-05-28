// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#if canImport(UIKit)
import UIKit
#endif

@available(iOS 1.0, *)
extension UIColor {
    convenience init?(_ colorAsset: ColorAsset) {
        self.init(named: colorAsset._name)
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
        let traits: [UIFontDescriptor.TraitKey: Any] = [
            .weight: descriptor.weight.flatMap(UIFont.Weight.init) ?? .regular
        ]

        var fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
            .traits: traits
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

@available(iOS 1.0, *)
public extension Style {
    var textAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(fontDescriptor),
        ]

        if let color = UIColor(colorAsset) {
            attributes[.foregroundColor] = color
        }

        return attributes
    }
}
