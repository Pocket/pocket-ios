//
//  SaveExtension.swift
//
//
//  Created by Daniel Brooks on 2/10/23.
//

import Foundation

public extension Events {
    struct SaveExtension {}
}

public extension Events.SaveExtension {
    static func Shown() -> Event {
        // TODO: Use right identifier
        return Engagement(
            .general,
            uiEntity: UiEntity(.dialog, identifier: "save.dialog.shown")
        )
    }

    static func Saved(url: URL) -> Event {
        // TODO: Use right identifier
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(.dialog, identifier: "save.dialog.saved")
        )
    }

    static func AddTagsShown(url: URL) -> Event {
        // TODO: Use right identifier
        return Engagement(
            uiEntity: UiEntity(.dialog, identifier: "save.dialog.tags.view"),
            extraEntities: [ContentEntity(url: url)]
        )
    }

    static func AddTagsDone(url: URL) -> Event {
        // TODO: Use right identifier
        return Engagement(
            uiEntity: UiEntity(.dialog, identifier: "save.dialog.tags.done"),
            extraEntities: [ContentEntity(url: url)]
        )
    }
}
