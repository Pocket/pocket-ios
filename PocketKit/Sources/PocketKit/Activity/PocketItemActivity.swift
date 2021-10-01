// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync


struct PocketItemActivity: PocketActivity {
    var applicationActivities: [UIActivity]? {
        [
            CopyLinkActivity(),
            CopyLinkWithSelectionActivity()
        ]
    }
    
    let activityItems: [Any]
   
    init(item: SavedItem, additionalText: String? = nil) {
        self.activityItems = Self.activityItems(for: item.url, additionalText: additionalText)
    }

    init(recommendation: Slate.Recommendation, additionalText: String? = nil) {
        self.activityItems = Self.activityItems(for: recommendation.url, additionalText: additionalText)
    }
    
    private static func activityItems(for url: URL?, additionalText: String?) -> [Any] {
        [
            url.flatMap(ActivityItemSource.init),
            additionalText.flatMap(ActivityItemSource.init)
        ].compactMap { $0 }
    }
}
