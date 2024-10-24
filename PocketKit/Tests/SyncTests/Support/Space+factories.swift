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
        tags: [CDTag]? = nil,
        item: CDItem? = nil
    ) throws -> CDSavedItem {
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
            try backgroundContext.save()

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
        tags: [CDTag]? = nil,
        item: CDItem? = nil
    ) -> CDSavedItem {
        backgroundContext.performAndWait {
            let savedItem: CDSavedItem = CDSavedItem(context: backgroundContext, url: url)
            savedItem.remoteID = remoteID
            savedItem.isFavorite = isFavorite
            savedItem.isArchived = isArchived
            savedItem.createdAt = createdAt
            savedItem.archivedAt = archivedAt
            savedItem.cursor = cursor
            savedItem.tags = NSOrderedSet(array: tags ?? [])
            savedItem.item = item ?? CDItem(context: backgroundContext, givenURL: url, remoteID: remoteID)

            return savedItem
        }
    }
}

// MARK: - SyndicatedArticle

extension Space {
    @discardableResult
    func createSyndicatedArticle(
        excerpt: String? = nil,
        imageURL: URL? = nil,
        itemID: String,
        publisherName: String? = nil,
        title: String,
        item: CDItem? = nil
    ) throws -> CDSyndicatedArticle {
        try backgroundContext.performAndWait {
            let syndicatedArticle = buildSyndicatedArticle(
                excerpt: excerpt,
                imageURL: imageURL,
                itemID: itemID,
                publisherName: publisherName,
                title: title,
                item: item
            )
            try backgroundContext.save()

            return syndicatedArticle
        }
    }

    @discardableResult
    func buildSyndicatedArticle(
        excerpt: String? = nil,
        imageURL: URL? = nil,
        itemID: String,
        publisherName: String? = nil,
        title: String,
        item: CDItem? = nil
    ) -> CDSyndicatedArticle {
        backgroundContext.performAndWait {
            let syndicatedArticle: CDSyndicatedArticle = CDSyndicatedArticle(context: backgroundContext)
            syndicatedArticle.excerpt = excerpt
            syndicatedArticle.imageURL = imageURL
            syndicatedArticle.itemID = itemID
            syndicatedArticle.publisherName = publisherName
            syndicatedArticle.title = title
            syndicatedArticle.item = item
            return syndicatedArticle
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
        syndicatedArticle: CDSyndicatedArticle? = nil
    ) throws -> CDItem {
        try backgroundContext.performAndWait {
            let item = buildItem(
                remoteID: remoteID,
                title: title,
                givenURL: givenURL,
                isArticle: isArticle,
                syndicatedArticle: syndicatedArticle
            )
            try backgroundContext.save()

            return item
        }
    }

    @discardableResult
    func buildItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: String? = "https://example.com/items/item-1",
        resolvedURL: String? = nil,
        isArticle: Bool = true,
        syndicatedArticle: CDSyndicatedArticle? = nil,
        num: Int? = nil
    ) -> CDItem {
        var url = givenURL
        if url == nil, let num = num {
            url = "https://example.com/items/item-1-\(num)"
        }

        return backgroundContext.performAndWait {
            let item: CDItem = CDItem(context: backgroundContext, givenURL: url!, remoteID: remoteID)
            item.title = title
            item.resolvedURL = resolvedURL
            item.isArticle = isArticle
            item.syndicatedArticle = syndicatedArticle

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
        slates: [CDSlate] = []
    ) throws -> CDSlateLineup {
        try backgroundContext.performAndWait {
            let slateLineup = buildSlateLineup(
                remoteID: remoteID,
                requestID: requestID,
                experimentID: experimentID,
                slates: slates
            )

            try backgroundContext.save()
            return slateLineup
        }
    }

    @discardableResult
    func buildSlateLineup(
        remoteID: String = "slate-lineup-1",
        requestID: String = "slate-lineup-1-request",
        experimentID: String = "slate-lineup-1-experiment",
        slates: [CDSlate] = []
    ) -> CDSlateLineup {
        backgroundContext.performAndWait {
            let lineup: CDSlateLineup = CDSlateLineup(context: backgroundContext, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
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
        recommendations: [CDRecommendation] = []
    ) throws -> CDSlate {
        try backgroundContext.performAndWait {
            let slate = buildSlate(
                experimentID: experimentID,
                remoteID: remoteID,
                name: name,
                requestID: requestID,
                slateDescription: slateDescription,
                recommendations: recommendations
            )

            try backgroundContext.save()
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
        recommendations: [CDRecommendation] = []
    ) -> CDSlate {
        backgroundContext.performAndWait {
            let slate: CDSlate = CDSlate(context: backgroundContext, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
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
        item: CDItem
    ) throws -> CDRecommendation {
        try backgroundContext.performAndWait {
            let recommendation = buildRecommendation(
                remoteID: remoteID,
                item: item
            )

            try backgroundContext.save()
            return recommendation
        }
    }

    @discardableResult
    func buildRecommendation(
        remoteID: String = "slate-1-rec-1",
        item: CDItem
    ) -> CDRecommendation {
        backgroundContext.performAndWait {
            let recommendation: CDRecommendation = CDRecommendation(context: backgroundContext, remoteID: remoteID, analyticsID: "")
            recommendation.item = item

            return recommendation
        }
    }
}
