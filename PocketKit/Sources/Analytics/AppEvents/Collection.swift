// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Events {
    struct Collection {}
}

public extension Events.Collection {
    /**
     * Fired when a user views the collection screen
     */
    static func screenView() -> Impression {
        return Impression(
            component: .screen,
            requirement: .instant,
            uiEntity: UiEntity(
                .screen,
                identifier: "collection.screen"
            )
        )
    }

    // MARK: Tracking Navbar Actions
    /**
     * Fired when a user Saves a card on a collection
     */
    static func saveClicked(url: String) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "collection.save"
            )
        )
    }

    /**
     * Fired when a user archives / unsaves a card on a collection
     */
    static func unsaveClicked(url: String) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "collection.unsave"
            )
        )
    }

    /**
     Fired when a user taps on the save icon in the collection nav bar and moves item from archive to save
     */
    static func moveFromArchiveToSavesClicked(url: String) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "collection.un-archive"
            )
        )
    }

    /**
     Fired when a user taps on overflow menu in nav bar within the collection screen
     */
    static func overflowClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on favorite in the overflow menu in nav bar within the collection screen if its a saved item
     */
    static func favoriteClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow.favorite"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on unfavorite in the overflow menu in nav bar within the collection screen if its a saved item
     */
    static func unfavoriteClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow.unfavorite"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on addTags in the overflow menu in nav bar within the collection screen if its a saved item
     */
    static func addTagsClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow.addTag"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on delete in the overflow menu in nav bar within the collection screen if its a saved item
     */
    static func deleteClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow.delete"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on share in the overflow menu in nav bar within the collection screen
     */
    static func shareClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow.share"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on report in the overflow menu in nav bar within the collection screen if its a recommendation item
     */
    static func reportClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.overflow.report"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    // MARK: Tracking Story
    /**
     * Fired when a user clicks a card on a collection
     */
    static func contentOpen(
        url: String
    ) -> ContentOpen {
        return ContentOpen(
            trigger: .click,
            contentEntity: ContentEntity(url: url),
            uiEntity: UiEntity(.card, identifier: "collection.story.open")
        )
    }

    /**
     * Fired when a user Saves a card on a collection
     */
    static func storySaveClicked(url: String) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "collection.story.save"
            )
        )
    }

    /**
     * Fired when a user unSaves a card on a collection
     */
    static func storyUnSaveClicked(url: String) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "collection.story.unsave"
            )
        )
    }

    /**
     Fired when a user taps on share button for a story in the overflow menu within the collection screen
     */
    static func storyShareClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.story.overflow.share"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user taps on report button for a story in the overflow menu within the collection screen
     */
    static func storyReportClicked(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "collection.story.overflow.report"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}
