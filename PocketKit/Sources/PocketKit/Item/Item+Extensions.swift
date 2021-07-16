// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Sync
import SwiftUI

public extension Item {
    var characterDirection: LayoutDirection {
        let language = language ?? "en"
        let direction = Locale.characterDirection(forLanguage: language)
        return direction == .rightToLeft ? .rightToLeft : .leftToRight
    }
}
