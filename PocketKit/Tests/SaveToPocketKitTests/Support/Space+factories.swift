// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import Sync

// MARK: - SavedItem
extension Space {
    @discardableResult
    func createSavedItem(
        remoteID: String = "saved-item-1",
        url: String = "http://example.com/item-1",
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        archivedAt: Date? = nil,
        cursor: String? = nil,
        tags: [String]? = nil,
        item: Item? = nil
    ) throws -> SavedItem {
        try backgroundContext.performAndWait {
            let savedItem = buildSavedItem(
                remoteID: remoteID,
                url: url,
                isFavorite: isFavorite,
                isArchived: isArchived,
                createdAt: createdAt,
                archivedAt: archivedAt,
                cursor: cursor,
                tags: tags,
                item: item
            )
            try save()

            return savedItem
        }
    }

    @discardableResult
    func buildSavedItem(
        remoteID: String = "saved-item-1",
        url: String = "http://example.com/item-1",
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        archivedAt: Date? = nil,
        cursor: String? = nil,
        tags: [String]? = nil,
        item: Item? = nil
    ) -> SavedItem {
        backgroundContext.performAndWait {
            let savedItem: SavedItem = SavedItem(context: backgroundContext, url: URL(string: url)!, remoteID: remoteID)
            let tags: [Tag]? = tags?.map { tag -> Tag in
                let newTag: Tag = Tag(context: backgroundContext)
                newTag.name = tag
                newTag.remoteID = tag.uppercased()
                return newTag
            }
            savedItem.remoteID = remoteID
            savedItem.isFavorite = isFavorite
            savedItem.isArchived = isArchived
            savedItem.createdAt = createdAt
            savedItem.archivedAt = archivedAt
            savedItem.url = URL(string: url)!
            savedItem.cursor = cursor
            savedItem.tags = NSOrderedSet(array: tags ?? [])
            savedItem.item = item ?? Item(context: backgroundContext, givenURL: url, remoteID: remoteID)

            return savedItem
        }
    }
}

// MARK: - Item
extension Space {
    @discardableResult
    func createItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: String = "https://example.com/items/item-1",
        isArticle: Bool = true,
        article: Article? = nil
    ) throws -> Item {
        try backgroundContext.performAndWait {
            let item = buildItem(
                remoteID: remoteID,
                title: title,
                givenURL: givenURL,
                isArticle: isArticle,
                article: article
            )
            try save()

            return item
        }
    }

    @discardableResult
    func buildItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: String = "https://example.com/items/item-1",
        resolvedURL: String? = nil,
        isArticle: Bool = true,
        article: Article? = nil
    ) -> Item {
        backgroundContext.performAndWait {
            let item: Item = Item(context: backgroundContext, givenURL: givenURL, remoteID: remoteID)
            item.remoteID = remoteID
            item.title = title
            item.resolvedURL = resolvedURL
            item.isArticle = isArticle
            item.article = article

            return item
        }
    }
}

// MARK: - SlateLineup
extension Space {
    @discardableResult
    func createSlateLineup(
        remoteID: String = "slate-lineup-1",
        requestID: String = "slate-lineup-1-request",
        experimentID: String = "slate-lineup-1-experiment",
        slates: [Slate] = []
    ) throws -> SlateLineup {
        try backgroundContext.performAndWait {
            let slateLineup = buildSlateLineup(
                remoteID: remoteID,
                requestID: requestID,
                experimentID: experimentID,
                slates: slates
            )

            try save()
            return slateLineup
        }
    }

    @discardableResult
    func buildSlateLineup(
        remoteID: String = "slate-lineup-1",
        requestID: String = "slate-lineup-1-request",
        experimentID: String = "slate-lineup-1-experiment",
        slates: [Slate] = []
    ) -> SlateLineup {
        backgroundContext.performAndWait {
            let lineup: SlateLineup = SlateLineup(context: backgroundContext, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
            lineup.slates = NSOrderedSet(array: slates)

            return lineup
        }
    }
}

// MARK: - Slate
extension Space {
    @discardableResult
    func createSlate(
        experimentID: String = "slate-1-experiment",
        remoteID: String = "slate-1",
        name: String = "Slate 1",
        requestID: String = "slate-1-request",
        slateDescription: String = "The description of slate 1",
        recommendations: [Recommendation] = []
    ) throws -> Slate {
        try backgroundContext.performAndWait {
            let slate = buildSlate(
                experimentID: experimentID,
                remoteID: remoteID,
                name: name,
                requestID: requestID,
                slateDescription: slateDescription,
                recommendations: recommendations
            )

            try save()
            return slate
        }
    }

    @discardableResult
    func buildSlate(
        experimentID: String = "slate-1-experiment",
        remoteID: String = "slate-1",
        name: String = "Slate 1",
        requestID: String = "slate-1-request",
        slateDescription: String = "The description of slate 1",
        recommendations: [Recommendation] = []
    ) -> Slate {
        backgroundContext.performAndWait {
            let slate: Slate = Slate(context: backgroundContext, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
            slate.name = name
            slate.slateDescription = slateDescription
            slate.recommendations = NSOrderedSet(array: recommendations)

            return slate
        }
    }
}

// MARK: - Recommendation
extension Space {
    @discardableResult
    func createRecommendation(
        remoteID: String = "slate-1-rec-1",
        item: Item
    ) throws -> Recommendation {
        try backgroundContext.performAndWait {
            let recommendation = buildRecommendation(
                remoteID: remoteID,
                item: item
            )

            try save()
            return recommendation
        }
    }

    @discardableResult
    func buildRecommendation(
        remoteID: String = "slate-1-rec-1",
        item: Item
    ) -> Recommendation {
        backgroundContext.performAndWait {
            let recommendation: Recommendation = Recommendation(context: backgroundContext, remoteID: remoteID, analyticsID: "")
            recommendation.item = item

            return recommendation
        }
    }
}

// MARK: - Image
extension Space {
    @discardableResult
    func buildImage(
        source: URL?,
        isDownloaded: Bool = false
    ) -> Image {
        return backgroundContext.performAndWait {
            let image: Image = Image(context: backgroundContext)
            image.source = source
            image.isDownloaded = isDownloaded

            return image
        }
    }

    @discardableResult
    func createImage(
        source: URL?,
        isDownloaded: Bool = false
    ) throws -> Image {
        return try backgroundContext.performAndWait {
            let image = buildImage(source: source, isDownloaded: isDownloaded)
            try save()

            return image
        }
    }
}
