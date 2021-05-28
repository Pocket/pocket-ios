// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI


public struct Style {
    var fontDescriptor: FontDescriptor
    var colorAsset: ColorAsset

    init(fontDescriptor: FontDescriptor, color: ColorAsset = .ui.grey1) {
        self.fontDescriptor = fontDescriptor
        self.colorAsset = color
    }
    
    init(
        family: FontDescriptor.Family? = nil,
        size: FontDescriptor.Size? = nil,
        weight: FontDescriptor.Weight? = nil,
        color: ColorAsset = .ui.grey1
    ) {
        self.init(
            fontDescriptor: FontDescriptor(
                family: family,
                size: size,
                weight: weight
            ),
            color: color
        )
    }
    
    public func with(size: FontDescriptor.Size) -> Style {
        Style(fontDescriptor: fontDescriptor.with(size: size), color: colorAsset)
    }

    public func with(family: FontDescriptor.Family) -> Style {
        Style(fontDescriptor: fontDescriptor.with(family: family), color: colorAsset)
    }

    public func with(weight: FontDescriptor.Weight) -> Style {
        return Style(fontDescriptor: fontDescriptor.with(weight: weight), color: colorAsset)
    }

    public func with(color: ColorAsset) -> Style {
        return Style(fontDescriptor: fontDescriptor, color: color)
    }
}
