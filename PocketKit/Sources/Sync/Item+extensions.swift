// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension CDItem {
    public var bestURL: String {
        resolvedURL ?? givenURL
    }

    public var hasImage: ItemImageness? {
        imageness.flatMap(ItemImageness.init)
    }

    public var hasVideo: ItemVideoness? {
        videoness.flatMap(ItemVideoness.init)
    }
}
