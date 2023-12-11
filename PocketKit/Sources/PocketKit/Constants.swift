// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit

enum Margins: CGFloat {
    case thin = 8
    case normal = 16
    case iPadNormal = 20
    case wide = 32
}

enum Width: CGFloat {
    case normal = 145
    case wide = 300
}

enum StyleConstants {
    static let thumbnailSize = CGSize(width: 90, height: 60)
    static let carouselHeight: CGFloat = 146
    static let sharedWithYouHeight: CGFloat = carouselHeight + 35
    static var groupHeight: CGFloat {
        return min(UIFontMetrics.default.scaledValue(for: carouselHeight), 300)
    }
}
