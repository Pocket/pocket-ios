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
        item?.bestURL ?? url
    }

    var isPending: Bool {
        item == nil
    }

    var shouldOpenInWebView: Bool {
        item?.shouldOpenInWebView == true
    }

    var isSyndicated: Bool {
        item?.isSyndicated == true
    }
}

public extension Item {
    var shouldOpenInWebView: Bool {
        if !isSaved && !isSyndicated {
            return true
        }

        return !isArticle || hasImage == .isImage || hasVideo == .isVideo
    }

    var isSyndicated: Bool {
        syndicatedArticle != nil
    }

    var isSaved: Bool {
        savedItem != nil
    }
}
