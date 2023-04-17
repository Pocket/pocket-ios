// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Sync

public extension SavedItem {
    var textAlignment: TextAlignment {
        TextAlignment(language: item.language)
    }

    var bestURL: URL? {
        item.bestURL ?? url
    }

    var isPending: Bool {
        item == nil
    }

    var shouldOpenInWebView: Bool {
        item.shouldOpenInWebView == true
    }

    var isSyndicated: Bool {
        item.isSyndicated == true
    }
}

public extension Item {
    var shouldOpenInWebView: Bool {
        if isSaved || isSyndicated {
            // We are legally allowed to open the item in reader view
            // BUT: if any of the following are true...
            // a) the item is not an article (i.e. it was not parseable)
            // b) the item is an image
            // c) the item is a video
            if !isArticle || isImage || isVideo {
                // then we should open in web view
                return true
            } else {
                // the item is safe to open in reader view
                return false
            }
        } else {
            // We are not legally allowed to open the item in reader view
            // open in web view
            return true
        }
    }

    var isSyndicated: Bool {
        syndicatedArticle != nil
    }

    var isSaved: Bool {
        savedItem != nil
    }

    var isVideo: Bool {
        hasVideo == .isVideo
    }

    var isImage: Bool {
        hasImage == .isImage
    }
}
