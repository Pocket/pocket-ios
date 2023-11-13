// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol StylerModifier {
    var fontSizeAdjustment: Int { get }
    var lineHeightScaleFactor: Double { get }
    var fontFamily: FontDescriptor.Family { get }

    var currentStyling: FontStyling { get }
}

public extension Style {
    func modified(by modifier: StylerModifier) -> Style {
        self.with(family: modifier.fontFamily)
            .adjustingSize(by: modifier.fontSizeAdjustment)
            .scalingLineHeight(by: modifier.lineHeightScaleFactor)
    }
}
