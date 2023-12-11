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

    /// The source of the item activity, e.g "pocket_home", which will
    /// be set as a utm_source query item of the item's url.
    private let source: String?

    let activityItems: [Any]
    let sender: Any?

    init(url: String, additionalText: String? = nil, source: String? = nil, sender: Any? = nil) {
        self.activityItems = Self.activityItems(for: url, additionalText: additionalText, source: source)
        self.sender = sender
        self.source = source
    }

    private static func activityItems(for url: String, additionalText: String?, source: String?) -> [Any] {
        // Append utm_source (using pocketShareURL) as necessary if there is a source, else use the original URL
        let itemSourceURL = source.flatMap { pocketShareURL(url, source: $0) } ?? url
        return [
            URL(percentEncoding: itemSourceURL).flatMap { ActivityItemSource($0) },
            additionalText.flatMap(ActivityItemSource.init)
        ].compactMap { $0 }
    }
}

extension PocketItemActivity {
    static func fromSaves(
        url: String,
        additionalText: String? = nil,
        sender: Any? = nil
    ) -> PocketItemActivity {
        return PocketItemActivity(
            url: url,
            additionalText: additionalText,
            source: "pocket_saves",
            sender: sender
        )
    }

    static func fromHome(url: String, additionalText: String? = nil, sender: Any? = nil) -> PocketItemActivity {
        return PocketItemActivity(
            url: url,
            additionalText: additionalText,
            source: "pocket_home",
            sender: sender
        )
    }

    static func fromReader(
        url: String,
        additionalText: String? = nil,
        sender: Any? = nil
    ) -> PocketItemActivity {
        return PocketItemActivity(
            url: url,
            additionalText: additionalText,
            source: "pocket_reader",
            sender: sender
        )
    }

    static func fromCollection(
        url: String,
        additionalText: String? = nil,
        sender: Any? = nil
    ) -> PocketItemActivity {
        return PocketItemActivity(
            url: url,
            additionalText: additionalText,
            source: "pocket_collection",
            sender: sender
        )
    }
}
