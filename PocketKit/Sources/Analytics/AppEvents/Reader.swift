//
//  File.swift
//  
//
//  Created by Daniel Brooks on 2/10/23.
//

import Foundation

public extension Events {
    struct Reader {}
}

public extension Events.Reader {
    static func ArticleShare(url: URL) -> Event {
        return Engagement(
            uiEntity: UiEntity(.button, identifier: "reader.share"),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    static func ArticleDelete(url: URL) -> Event {
        return Engagement(
            uiEntity: UiEntity(.button, identifier: "reader.delete"),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    static func ArticleViewOriginal(url: URL) -> Event {
        return Engagement(
            uiEntity: UiEntity(.button, identifier: "reader.view-original"),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }
}
