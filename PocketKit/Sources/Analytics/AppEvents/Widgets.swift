// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Widgets {}
}

public extension Events.Widgets {
    /// Fired when a user taps a card in the `Recent Saves Widget`
    static func recentSavesCardContentOpen(url: String) -> ContentOpen {
        return ContentOpen(
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "widget.recent.open"
            )
        )
    }

     /// Fired when a user taps a card in the `Recommendations Widget`
    static func slateArticleContentOpen(url: String, recommendationId: String, destination: ContentOpen.Destination) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "widget.slate.article.open"
            ),
            extraEntities: [
                ContentEntity(url: url),
                CorpusRecommendationEntity(id: recommendationId)
            ]
        )
    }
}
