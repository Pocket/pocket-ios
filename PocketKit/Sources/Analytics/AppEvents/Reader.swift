// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Reader {}
}

public extension Events.Reader {
    /**
     Fired when the user views an unsupported content cell in the `Reader`
     */
    static func unsupportedContentViewed(url: String) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "reader.unsupportedContent"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when the user taps on the button in the unsupported content cell in the `Reader`
     */
    static func unsupportedContentButtonTapped(url: String) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "reader.unsupportedContent.open"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /**
     Fired when a user un-archives/adds an article to Saves via the top toolbar on Reader
     */
    static func moveFromArchiveToSavesClicked(url: String) -> Engagement {
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
    static func archiveClicked(url: String) -> Engagement {
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
     Fired when the user taps on the button to open item in web view  in the `Reader`
     */
    static func openInWebView(url: String) -> ContentOpen {
        return ContentOpen(
            contentEntity: ContentEntity(url: url),
            uiEntity: UiEntity(
                .button,
                identifier: "reader.view-original"
            )
        )
    }

    static func openExternalLink(url: String) -> ContentOpen {
        return ContentOpen(
            contentEntity: ContentEntity(url: url),
            uiEntity: UiEntity(
                .button,
                identifier: "reader.external-link"
            )
        )
    }

    /// User taps the `Highlight` button in the context menu of a selection
    static func addHighlight() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "reader.add-highlight"
            )
        )
    }

    /// User taps the remove (trash icon) button on an highlight in the highlights list modal
    static func removeHighlight() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "reader.remove-highlight"
            )
        )
    }

    /// User taps the share (icon) button on an highlight in the highlights list modal
    static func shareHighlight() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "reader.share-highlight"
            )
        )
    }

    /// User taps the `Highlights` button in the overflow menu
    static func highlightUpsellViewed() -> Event {
        return Impression(
            component: .ui,
            requirement: .viewable,
            uiEntity: UiEntity(
                .dialog,
                identifier: "reader.upsell-highlight"
            )
        )
    }
}
