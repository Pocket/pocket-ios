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
    static func saveTags(itemUrl: String) -> Event {
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
    /// - Parameters:
    ///     - tag: The tag added to an item.
    ///     - itemUrl: The url of the item to which a new tag was added.
    static func addTag(_ tag: String, itemUrl: String) -> Event {
        return Engagement(
            .general,
            value: tag,
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
    /// - Parameters:
    ///     - tag: The tag that was removed from the list of input tags.
    ///     ///     - itemUrl: The url of the item to which a tag was removed.
    static func removeInputTag(_ tag: String, itemUrl: String) -> Event {
        return Engagement(
            .general,
            value: tag,
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
    static func userEntersText(itemUrl: String, text: String) -> Event {
        return Engagement(
            .general,
            value: text,
            uiEntity: UiEntity(
                .dialog,
                identifier: "global-nav.addTags.userEntersText"
            ),
            extraEntities: [
                ContentEntity(
                    url: itemUrl
                )
            ]
        )
    }

    /// Fired when a user views all of their tags in the `Add Tags` screen for an item
    static func allTagsImpression(itemUrl: String) -> Event {
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
    static func filteredTagsImpression(itemUrl: String) -> Event {
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
    static func premiumUpsellViewed(itemURL: String) -> Event {
        return Impression(
            component: .button,
            requirement: .viewable,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.upsell"
            ),
            extraEntities: [
                ContentEntity(url: itemURL)
            ]
        )
    }

    /// Fired when a user taps on a general tag from `Add Tags` screen
    /// - Parameters:
    ///     - tag: The tag selected to add to an item.
    static func selectTagToAddToItem(_ tag: String) -> Event {
        return Engagement(
            .general,
            value: tag,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.selectTag"
            )
        )
    }

    /// Fired when a user taps on a recent tag from `Add Tags` screen
    /// - Parameters:
    ///     - tag: The recent tag selected to add to an item.
    static func selectRecentTagToAddToItem(_ tag: String) -> Event {
        return Engagement(
            .general,
            value: tag,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.addTags.selectRecentTag"
            )
        )
    }

    /// Fired when a user selects on a general tag using the `Tags` screen after tapping on `Tagged` filter
    /// - Parameters:
    ///     - tag: The tag that was selected as the filter.
    static func selectTagToFilter(_ tag: String) -> Event {
        return Engagement(
            .general,
            value: tag,
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
    /// - Parameters:
    ///     - tag: The recent tag that was selected as the filter.
    static func selectRecentTagToFilter(_ tag: String) -> Event {
        return Engagement(
            .general,
            value: tag,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.filterTags.selectRecentTag"
            )
        )
    }

    /// Fired when a user adds tag to an input list in the `Add Tags` screen for an item
    /// - Parameters:
    ///     - from: The previous name of the tag before rename.
    ///     - to: The new name of the tag after rename.
    static func renameTag(from oldTag: String, to newTag: String) -> Event {
        return Engagement(
            .general,
            value: [oldTag, newTag].joined(separator: ","),
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.filterTags.tagRename"
            )
        )
    }

    /// Fired when a user confirms to delete tags from 'Tags' screen after tapping on `Tagged` filter
    /// - Parameters:
    ///     - tags: An array of tags that were deleted; used to generate a comma-separated string as a value.
    static func deleteTags(_ tags: [String]) -> Event {
        return Engagement(
            .general,
            value: tags.joined(separator: ","),
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.filterTags.tagsDelete"
            )
        )
    }
}
