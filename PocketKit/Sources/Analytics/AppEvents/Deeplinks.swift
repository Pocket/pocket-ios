// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Deeplinks {}
}

public extension Events.Deeplinks {
     /// Fired when a user taps an external deeplink into Pocket
    static func deeplinkArticleContentOpen(url: String, destination: ContentOpen.Destination) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "deeplink.article.open"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}
