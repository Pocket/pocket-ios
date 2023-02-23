// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct Search {}
}

public extension Events.Search {
    private static func getScopeIdentifier(scope: SearchScope) -> String {
        switch scope {
        case .saves:
            return "saves"
        case .archive:
            return "archive"
        case .all:
            return "all_items"
        }
    }

    static func favoriteItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.favorite",
                componentDetail: getScopeIdentifier(scope: scope),
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    static func unfavoriteItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.unfavorite",
                componentDetail: getScopeIdentifier(scope: scope),
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    static func shareItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.share",
                componentDetail: getScopeIdentifier(scope: scope),
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }
}
