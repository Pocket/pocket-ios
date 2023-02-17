//
//  File.swift
//  
//
//  Created by Daniel Brooks on 2/17/23.
//

import Foundation
public extension Events {
    struct Home {}
}

public extension Events.Home {
    /**
     Fired when a card in the `Recent Saves` section scrolls into view
     */
    static func RecentSavesCardImpression(url: URL!, positionInList: Int, itemId: String?) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.recent.impression",
                index: positionInList),
            extraEntities: [
                ContentEntity(url: url, itemId: itemId)
            ]
        )
    }

    /**
     Fired when a user clicks a card in the `Recent Saves` section
     */
    static func RecentSavesCardContentOpen(url: URL!, positionInList: Int, itemId: String?) -> ContentOpen {
        return ContentOpen(
            contentEntity:
                ContentEntity(url: url, itemId: itemId),
            uiEntity: UiEntity(
                .card,
                identifier: "home.recent.open",
                index: positionInList)
        )
    }
}
