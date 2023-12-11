// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph

public enum ItemImageness: String, Equatable, Hashable {
    case noImages = "NO_IMAGES"
    case hasImages = "HAS_IMAGES"
    case isImage = "IS_IMAGE"
}

extension Imageness {
    init(imageness: ItemImageness) {
        switch imageness {
        case .noImages:
            self = .noImages
        case .hasImages:
            self = .hasImages
        case .isImage:
            self = .isImage
        }
    }
}
