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
        tags: [String]? = nil,
        item: CDItem? = nil
    ) -> CDSavedItem {
        backgroundContext.performAndWait {
            let savedItem: CDSavedItem = CDSavedItem(context: backgroundContext, url: url)
            let tags: [CDTag]? = tags?.map { tag -> CDTag in
                let newTag: CDTag = CDTag(context: backgroundContext)
                newTag.name = tag
                newTag.remoteID = tag.uppercased() // making remote id different by uppercasing.
                return newTag
            }
            savedItem.remoteID = remoteID
            savedItem.isFavorite = isFavorite
            savedItem.isArchived = isArchived
            savedItem.createdAt = createdAt
            savedItem.archivedAt = archivedAt
            savedItem.url = url
            savedItem.cursor = cursor
            savedItem.tags = NSOrderedSet(array: tags ?? [])
            savedItem.item = item ?? CDItem(context: backgroundContext, givenURL: url, remoteID: remoteID)

            return savedItem
        }
    }

    @discardableResult
        func buildPendingSavedItem() -> CDSavedItem {
            backgroundContext.performAndWait {
                let savedItem: CDSavedItem = CDSavedItem(context: backgroundContext, url: "https://mozilla.com/example")
                savedItem.createdAt = Date()
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
    ) throws -> CDItem {
        return try backgroundContext.performAndWait {
            let item = buildItem(
                remoteID: remoteID,
                title: title,
                givenURL: givenURL,
                isArticle: isArticle,
                article: article
            )
            try backgroundContext.save()

            return item
        }
    }

    @discardableResult
    func buildItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: String = "https://example.com/items/item-1",
        resolvedURL: String? = nil,
        topImageURL: URL? = nil,
        excerpt: String? = nil,
        isArticle: Bool = true,
        article: Article? = nil,
        syndicatedArticle: CDSyndicatedArticle? = nil
    ) -> CDItem {
        return backgroundContext.performAndWait {
            let item: CDItem = CDItem(context: backgroundContext, givenURL: givenURL, remoteID: remoteID)
            item.remoteID = remoteID
            item.title = title
            item.resolvedURL = resolvedURL
            item.isArticle = isArticle
            item.article = article
            item.topImageURL = topImageURL
            item.excerpt = excerpt
            item.syndicatedArticle = syndicatedArticle
            return item
        }
    }
}

// MARK: - Collection
extension Space {
    @discardableResult
    func buildCollection(
        slug: String = "slug-1",
        title: String = "collection-title",
        authors: [String] = [],
        stories: [CDCollectionStory] = [],
        item: CDItem? = nil
    ) -> CDCollection {
        backgroundContext.performAndWait {
            let collection: CDCollection = CDCollection(context: backgroundContext, slug: slug, title: title, authors: NSOrderedSet(array: authors), stories: NSOrderedSet(array: stories))
            collection.item = item

            return collection
        }
    }

    @discardableResult
    func buildCollectionStory(
        url: String = "story-url",
        title: String = "story-title",
        excerpt: String = "",
        authors: [String] = [],
        item: CDItem? = nil
    ) -> CDCollectionStory {
        backgroundContext.performAndWait {
            let collectionStory: CDCollectionStory = CDCollectionStory(context: backgroundContext, url: url, title: title, excerpt: excerpt, authors: NSOrderedSet(array: authors))
            collectionStory.item = item
            return collectionStory
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
            var i = 1
            lineup.slates?.forEach { slate in
                let slate = slate as! CDSlate
                slate.sortIndex = NSNumber(value: i)
                i = i + 1
            }

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

            var i = 1
            slate.recommendations?.forEach { rec in
                var rec = rec as! CDRecommendation
                rec.sortIndex = NSNumber(value: i)
                i = i + 1
            }

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
        item: CDItem,
        imageURL: URL? = nil,
        title: String? = nil,
        excerpt: String?  = nil,
        analyticsID: String = ""
    ) -> CDRecommendation {
        backgroundContext.performAndWait {
            let recommendation: CDRecommendation = CDRecommendation(context: backgroundContext, remoteID: remoteID, analyticsID: analyticsID)
            recommendation.item = item
            recommendation.title = title
            recommendation.excerpt = excerpt
            recommendation.imageURL = imageURL
            recommendation.analyticsID = analyticsID
            return recommendation
        }
    }
}

// MARK: - Syndication
extension Space {
    @discardableResult
    func buildSyndicatedArticle(
        title: String = "Syndicated Article 1",
        imageURL: URL? = nil,
        excerpt: String? = nil,
        publisherName: String? = nil
    ) -> CDSyndicatedArticle {
        backgroundContext.performAndWait {
            let syndicatedArticle: CDSyndicatedArticle = CDSyndicatedArticle(context: backgroundContext)
            syndicatedArticle.title = title
            syndicatedArticle.imageURL = imageURL
            syndicatedArticle.excerpt  = excerpt
            syndicatedArticle.publisherName = publisherName
            return syndicatedArticle
        }
    }
}

// MARK: - Image
extension Space {
    @discardableResult
    func buildImage(
        source: URL?,
        isDownloaded: Bool = false,
        item: CDItem? = nil
    ) -> CDImage {
        return backgroundContext.performAndWait {
            let image: CDImage = CDImage(context: backgroundContext)
            image.source = source
            image.isDownloaded = isDownloaded
            image.item = item

            return image
        }
    }

    @discardableResult
    func createImage(
        source: URL?,
        isDownloaded: Bool = false,
        item: CDItem? = nil
    ) throws -> CDImage {
        return try backgroundContext.performAndWait {
            let image = buildImage(
                source: source,
                isDownloaded: isDownloaded,
                item: item
            )
            try backgroundContext.save()

            return image
        }
    }
}
