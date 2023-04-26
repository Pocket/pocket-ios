//
//  File.swift
//  
//
//  Created by David Skuza on 4/24/23.
//

import Foundation

public extension Events {
    struct SaveTo {}
}

public extension Events.SaveTo {
    struct Tags { }
}

public extension Events.SaveTo {
    /// Fired when a user opens the Save extension, since we cannot directly interact with
    /// the tapping of the icon from the share sheet. The Save extension is the entrypoint
    /// for that tap, so treat the opening of the Save extension as an engagement.
    static func saveEngagement(url: URL) -> Event {
        return Engagement(
            uiEntity: UiEntity(
                .screen,
                identifier: "save-extension.opened"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /// Fired when a user taps on "Add Tags" from the Save extension
    static func addTagsEngagement(url: URL) -> Event {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "save-extension.addTags.opened"
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}

public extension Events.SaveTo.Tags {
    /// Fired when user taps on "Save" button in `Add Tags` screen for an item
    static func saveTags(itemUrl: URL) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "save-extension.addTags.save"
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
    static func addTag(_ tag: String, itemUrl: URL) -> Event {
        return Engagement(
            .general,
            value: tag,
            uiEntity: UiEntity(
                .button,
                identifier: "save-extension.addTags.addTag"
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
    ///     - itemUrl: The url of the item to which a tag was removed.
    static func removeInputTag(_ tag: String, itemUrl: URL) -> Event {
        return Engagement(
            .general,
            value: tag,
            uiEntity: UiEntity(
                .button,
                identifier: "save-extension.addTags.removeInputTag"
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
                identifier: "save-extension.addTags.userEntersText",
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
                identifier: "save-extension.addTags.allTags"
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
                identifier: "save-extension.addTags.filteredTags"
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
                identifier: "save-extension.addTags.upsell"
            )
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
                identifier: "save-extension.addTags.selectTag"
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
                identifier: "save-extension.addTags.selectRecentTag"
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
                identifier: "save-extension.filterTags.selectTag"
            )
        )
    }

    /// Fired when a user selects `not tagged` using the `Tags` screen after tapping on `Tagged` filter
    static func selectNotTaggedToFilter() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "save-extension.filterTags.selectNotTagged"
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
                identifier: "save-extension.filterTags.selectRecentTag"
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
                identifier: "save-extension.filterTags.tagRename"
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
                identifier: "save-extension.filterTags.tagsDelete"
            )
        )
    }

}
