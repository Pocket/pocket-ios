// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct ReaderToolbar {}
}

public extension Events.ReaderToolbar {
    /**
     Fired when a user un-archives/adds an article to Saves via the top toolbar on Reader
     */
    static func moveFromArchiveToSavesClicked(url: URL) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "reader.un-archive"
            )
        )
    }

    /**
     Fired when a user archives an article via the top toolbar on Reader
     */
    static func archiveClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.archive"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the overflow button from within the reader toolbar
     */
    static func overflowClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.overflow"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the text settings button from within the reader toolbar overflow menu
     */
    static func textSettingsClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.text_settings"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the favorite button from within the reader toolbar overflow menu
     */
    static func favoriteClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.favorite"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the unfavorite button from within the reader toolbar overflow menu
     */
    static func unfavoriteClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.unfavorite"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the add tags button from within the reader toolbar overflow menu
     */
    static func addTagsClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.addTags"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the delete button from within the reader toolbar overflow menu
     */
    static func deleteClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.delete"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the save button from within the reader toolbar
     */
    static func saveClicked(url: URL) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.save"
            )
        )
    }

    /**
     Fired when a user clicks the share button from within the reader toolbar
     */
    static func shareClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.share"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user clicks the report button from within the reader toolbar
     */
    static func reportClicked(url: URL) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.toolbar.report"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}
