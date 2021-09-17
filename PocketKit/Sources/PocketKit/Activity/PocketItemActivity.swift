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
   
    init(item: Item, additionalText: String? = nil) {
        self.activityItems = Self.activityItems(for: item, additionalText: additionalText)
    }
    
    private static func activityItems(for item: Item, additionalText: String?) -> [Any] {
        let items = [
            item.url.flatMap(ActivityItemSource.init),
            additionalText.flatMap(ActivityItemSource.init)
        ].compactMap { $0 }
        return items
    }
}
