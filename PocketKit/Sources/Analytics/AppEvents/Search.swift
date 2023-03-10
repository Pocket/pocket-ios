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

    /**
     Fired when a user clicks the Favorite icon in a card for `Search`
     */
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

    /**
     Fired when a user clicks the Un-Favorite icon in a card for `Search`
     */
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

    /**
     Fired when a user shares a card in `Search`
     */
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

    /**
     Fired when a user clicks the Delete option in the overflow menu in a card for `Search`
     */
    static func deleteItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.delete",
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

    /**
     Fired when a user clicks the Archive option in the overflow menu in a card for `Search`
     */
    static func archiveItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.archive",
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

    /**
     Fired when a user clicks the Unarchive option in the overflow menu in a card for `Search`
     */
    static func unarchiveItem(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.unarchive",
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

    /**
     Fired when a user clicks the Unarchive option in the overflow menu in a card for `Search`
     */
    static func overFlowMenu(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.overflow",
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

    /**
     Fired when a user clicks the Add Tags option in the overflow menu in a card for `Search`
     */
    static func showAddTags(
        itemUrl: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.addTags",
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

    /**
     Fired when a user opens `Search` experience
     */
    static func openSearch(
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search",
                componentDetail: getScopeIdentifier(scope: scope)
            )
        )
    }

    /**
     Fired when a user submits a search term
     */
    static func submitSearch(
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.submit",
                componentDetail: getScopeIdentifier(scope: scope)
            )
        )
    }
    /**
     Fired when a user changes `Search` scope
     */
    static func switchScope(
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.switchscope",
                componentDetail: getScopeIdentifier(scope: scope)
            )
        )
    }

    /**
     Fired when a card in the `Search` comes into view
     */
    static func searchCardImpression(
        url: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "global-nav.search.impression",
                componentDetail: getScopeIdentifier(scope: scope),
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks a card in the `Search`
     */
    static func searchCardContentOpen(
        url: URL,
        positionInList: Int,
        scope: SearchScope
    ) -> ContentOpen {
        return ContentOpen(
            contentEntity:
                ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "global-nav.search.card.open",
                componentDetail: getScopeIdentifier(scope: scope),
                index: positionInList
            )
        )
    }

    /**
     Fired when a user scrolls down the search list and triggers another results page call
     */
    static func searchResultsPage(
        numberOfItems: Int,
        scope: SearchScope
    ) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .page,
                identifier: "global-nav.search.searchPage",
                componentDetail: getScopeIdentifier(scope: scope),
                index: numberOfItems
            )
        )
    }

    /// Premium upsell in Search visible
    static func premiumUpsellViewed() -> Event {
        return Impression(
            component: .button,
            requirement: .viewable,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.search.premium.upsell"
            )
        )
    }
}
