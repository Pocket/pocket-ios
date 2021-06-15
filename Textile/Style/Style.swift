// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI


public struct Style {
    var fontDescriptor: FontDescriptor
    var colorAsset: ColorAsset
    var underlineStyle: UnderlineStyle
    var strike: Strike

    init(
        fontDescriptor: FontDescriptor,
        color: ColorAsset = .ui.grey1,
        underlineStyle: UnderlineStyle = .none,
        strike: Strike = .none
    ) {
        self.fontDescriptor = fontDescriptor
        self.colorAsset = color
        self.underlineStyle = underlineStyle
        self.strike = strike
    }
    
    init(
        family: FontDescriptor.Family? = nil,
        size: FontDescriptor.Size? = nil,
        weight: FontDescriptor.Weight? = nil,
        color: ColorAsset = .ui.grey1,
        underlineStyle: UnderlineStyle = .none,
        strike: Strike = .none
    ) {
        self.init(
            fontDescriptor: FontDescriptor(
                family: family,
                size: size,
                weight: weight
            ),
            color: color,
            underlineStyle: underlineStyle,
            strike: strike
        )
    }
    
    public func with(size: FontDescriptor.Size) -> Style {
        return Style(fontDescriptor: fontDescriptor.with(size: size), color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }

    public func with(family: FontDescriptor.Family) -> Style {
        return Style(fontDescriptor: fontDescriptor.with(family: family), color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }

    public func with(weight: FontDescriptor.Weight) -> Style {
        return Style(fontDescriptor: fontDescriptor.with(weight: weight), color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }

    public func with(slant: FontDescriptor.Slant) -> Style {
        return Style(fontDescriptor: fontDescriptor.with(slant: slant), color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }

    public func with(color: ColorAsset) -> Style {
        return Style(fontDescriptor: fontDescriptor, color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }

    public func with(underlineStyle: UnderlineStyle) -> Style {
        return Style(fontDescriptor: fontDescriptor, color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }

    public func with(strike: Strike) -> Style {
        return Style(fontDescriptor: fontDescriptor, color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }
    
    public func adjustingSize(by adjustment: Int) -> Style {
        return Style(fontDescriptor: fontDescriptor.adjustingSize(by: adjustment), color: colorAsset, underlineStyle: underlineStyle, strike: strike)
    }
}
