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
    let sender: Any?
    
    init(url: URL?, additionalText: String? = nil, sender: Any? = nil) {
        self.activityItems = Self.activityItems(for: url, additionalText: additionalText)
        self.sender = sender
    }
    
    private static func activityItems(for url: URL?, additionalText: String?) -> [Any] {
        [
            url.flatMap(ActivityItemSource.init),
            additionalText.flatMap(ActivityItemSource.init)
        ].compactMap { $0 }
    }
}
