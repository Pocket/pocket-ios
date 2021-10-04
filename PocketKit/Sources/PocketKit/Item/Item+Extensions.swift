// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Sync

public extension SavedItem {
    var textAlignment: TextAlignment {
        TextAlignment(language: item?.language)
    }

    var bestURL: URL? {
        item?.resolvedURL ?? item?.givenURL ?? url
    }
}
