// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph

public enum ItemVideoness: String, Equatable, Hashable {
    case noVideos = "NO_VIDEOS"
    case hasVideos = "HAS_VIDEOS"
    case isVideo = "IS_VIDEO"
}

extension Videoness {
    init(videoness: ItemVideoness) {
        switch videoness {
        case .noVideos:
            self = .noVideos
        case .hasVideos:
            self = .hasVideos
        case .isVideo:
            self = .isVideo
        }
    }
}
