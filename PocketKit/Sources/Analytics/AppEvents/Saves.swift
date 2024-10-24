// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Events {
    struct Saves { }
}

public extension Events.Saves {
    /// Returns a ContentOpen event for a url that was opened within Saves
    /// - Parameters:
    ///     - destination: Internal, or external, based on whether the content was opened in the reader or web view, respectively
    ///     - trigger: What triggered the content open; defaults to '.click'
    ///     - url: The url of the content that was opened
    static func contentOpen(
        destination: ContentOpen.Destination,
        trigger: ContentOpen.Trigger = .click,
        url: String,
        listType: String?
    ) -> ContentOpen {
        return ContentOpen(
            destination: destination,
            trigger: trigger,
            contentEntity: ContentEntity(url: url),
            uiEntity: UiEntity(.card, identifier: "saves.card.open", componentDetail: listType)
        )
    }

    static func cardViewed(_ index: Int?, listType: String?) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "saves.card.impression",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func userDidOpenAddSavedItem() -> Impression {
        Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(.screen, identifier: "saves.addItem.open")
        )
    }

    static func userDidDismissAddSavedItem() -> Engagement {
        Engagement(uiEntity: UiEntity(.button, identifier: "saves.addItem.dismiss"))
    }

    static func userDidSaveItem(saveSucceeded: Bool) -> Engagement {
        let identifier = saveSucceeded ? "saves.addItem.success" : "saves.addItem.fail"

        return Engagement(uiEntity: UiEntity(.button, identifier: identifier))
    }

    static func archiveItem(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.archive",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func favoriteItem(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.favorite",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func unFavoriteItem(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.un-favorite",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func unArchiveItem(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.unarchive",
                index: index
            )
        )
    }

    static func deleteItem(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.delete",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func shareItem(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.share",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func overflow(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.overflow",
                componentDetail: listType,
                index: index
            )
        )
    }

    static func overflowEditTags(_ index: Int?, listType: String?) -> Engagement {
        Engagement(
            uiEntity: UiEntity(
                .card,
                identifier: "saves.overflow.edittags",
                componentDetail: listType,
                index: index
            )
        )
    }
}
