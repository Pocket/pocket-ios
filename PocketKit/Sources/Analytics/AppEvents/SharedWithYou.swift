// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Events {
    struct SharedWithYou {}
}

public extension Events.SharedWithYou {
    /// Shared With You list viewed
    static func screenView() -> Impression {
        return Impression(
            component: .screen,
            requirement: .instant,
            uiEntity: UiEntity(
                .screen,
                identifier: "sharedWithYou.screen"
            )
        )
    }

    /// Shared With You card viewed
    static func cardImpression(url: String, index: Int) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "sharedWithYou.card.impression",
                index: index
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /// Shared With You card tapped
    static func contentOpen(url: String, index: Int, destination: ContentOpen.Destination) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            trigger: .click,
            contentEntity: ContentEntity(url: url),
            uiEntity: UiEntity(
                .card,
                identifier: "sharedWithYou.item.open",
                index: index
            )
        )
    }

    /// Shared With You item saved
    static func itemSaved(url: String, index: Int) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "sharedWithYou.item.save",
                index: index
            )
        )
    }

    /// Shared With You item unsaved
    static func itemArchived(url: String, index: Int) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "sharedWithYou.item.archive",
                index: index
            )
        )
    }

    /// Shared With You item shared from the overflow menu
    static func itemShared(url: String, index: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "sharedWithYou.item.overflow.share",
                index: index
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}
