// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct Tags {}
}

public extension Events.Tags {
    /// Fired when user taps on "Save" button in `Add Tags` screen for an item
    static func saveTags(itemUrl: URL) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.save"
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    /// Fired when a user adds tag to an input list in the `Add Tags` screen for an item
    static func addTag(itemUrl: URL) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.addTag"
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    /// Fired when user taps on a tag name and removes it from the list of input tags in `Add Tags` screen for an item
    static func remoteInputTag(itemUrl: URL) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.removeInputTag"
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    /// Fired when a user enters text in the text field in the `Add Tags` screen for an item and includes component detail of text user entered
    static func userEntersText(itemUrl: URL, text: String) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .dialog,
                identifier: "global-nav.addTags.userEntersText",
                componentDetail: text
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    /// Fired when a user views all of their tags in the `Add Tags` screen for an item
    static func allTagsImpression(itemUrl: URL) -> Event {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.addTags.allTags"
            ),
            extraEntities: [
                ContentEntity(url: itemUrl)
            ]
        )
    }

    /// Fired when a user views filtered tags in the `Add Tags` screen for an item
    static func filteredTagsImpression(itemUrl: URL) -> Event {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.addTags.filteredTags"
            ),
            extraEntities: [
                ContentEntity(url: itemUrl)
            ]
        )
    }

    /// "Go Premium" button viewed
    static func premiumUpsellViewed() -> Event {
        return Impression(
            component: .button,
            requirement: .viewable,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.upsell"
            )
        )
    }

    /// Fired when a user taps on a general tag from `Add Tags` screen
    static func selectTagToAddToItem() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.selectTag"
            )
        )
    }

    /// Fired when a user taps on a recent tag from `Add Tags` screen
    static func selectRecentTagToAddToItem() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.selectRecentTag"
            )
        )
    }

    /// Fired when a user selects on a general tag using the `Tags` screen after tapping on `Tagged` filter
    static func selectTagToFilter() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.filterTags.selectTag"
            )
        )
    }

    /// Fired when a user selects `not tagged` using the `Tags` screen after tapping on `Tagged` filter
    static func selectNotTaggedToFilter() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.filterTags.selectNotTagged"
            )
        )
    }

    /// Fired when a user selects on a recent tag using the `Tags` screen after tapping on `Tagged` filter
    static func selectRecentTagToFilter() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.filterTags.selectRecentTag"
            )
        )
    }
}
