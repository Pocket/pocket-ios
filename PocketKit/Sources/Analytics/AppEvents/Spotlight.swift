// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Spotlight {}
}

public extension Events.Spotlight {
    /// Fired when a user taps an Item from `Spotlight Search`
    static func spotlightSearchContentOpen(url: String) -> ContentOpen {
        return ContentOpen(
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "spotlight.open"
            )
        )
    }
}
