// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct Search {}
}

public extension Events.Search {
    static func favoriteItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        var identifier = ""
        switch scope {
        case .saves:
            identifier = "global-nav.search.saves.favorite"
        case .archive:
            identifier = "global-nav.search.archive.favorite"
        case .all:
            identifier = "global-nav.search.all.favorite"
        }

        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: identifier,
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
        var identifier = ""
        switch scope {
        case .saves:
            identifier = "global-nav.search.saves.unfavorite"
        case .archive:
            identifier = "global-nav.search.archive.unfavorite"
        case .all:
            identifier = "global-nav.search.all.unfavorite"
        }

        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: identifier,
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
