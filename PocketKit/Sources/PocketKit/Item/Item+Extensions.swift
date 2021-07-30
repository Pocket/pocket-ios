// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Sync

public extension Item {
    var textAlignment: TextAlignment {
        let direction = Locale.characterDirection(forLanguage: language ?? "en")

        switch direction {
        case .rightToLeft:
            return .right
        case .unknown, .leftToRight, .topToBottom, .bottomToTop:
            return .left
        @unknown default:
            return .left
        }
    }
}
