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
        item: Item? = nil
    ) -> SavedItem {
        backgroundContext.performAndWait {
            let savedItem: SavedItem = SavedItem(context: backgroundContext, url: url)
            let tags: [Tag]? = tags?.map { tag -> Tag in
                let newTag: Tag = Tag(context: backgroundContext)
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
            savedItem.item = item ?? Item(context: backgroundContext, givenURL: url, remoteID: remoteID)

            return savedItem
        }
    }

    @discardableResult
        func buildPendingSavedItem() -> SavedItem {
            backgroundContext.performAndWait {
                let savedItem: SavedItem = SavedItem(context: backgroundContext, url: "https://mozilla.com/example")
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
    ) throws -> Item {
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
        syndicatedArticle: SyndicatedArticle? = nil
    ) -> Item {
        return backgroundContext.performAndWait {
            let item: Item = Item(context: backgroundContext, givenURL: givenURL, remoteID: remoteID)
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
        stories: [CollectionStory] = [],
        item: Item? = nil
    ) -> Collection {
        backgroundContext.performAndWait {
            let collection: Collection = Collection(context: backgroundContext, slug: slug, title: title, authors: NSOrderedSet(array: authors), stories: NSOrderedSet(array: stories))
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
        item: Item? = nil
    ) -> CollectionStory {
        backgroundContext.performAndWait {
            let collectionStory: CollectionStory = CollectionStory(context: backgroundContext, url: url, title: title, excerpt: excerpt, authors: NSOrderedSet(array: authors))
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
        slates: [Slate] = []
    ) throws -> SlateLineup {
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
        slates: [Slate] = []
    ) -> SlateLineup {
        backgroundContext.performAndWait {
            let lineup: SlateLineup = SlateLineup(context: backgroundContext, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
            lineup.slates = NSOrderedSet(array: slates)
            var i = 1
            lineup.slates?.forEach { slate in
                let slate = slate as! Slate
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
        recommendations: [Recommendation] = []
    ) -> Slate {
        backgroundContext.performAndWait {
            let slate: Slate = Slate(context: backgroundContext, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
            slate.name = name
            slate.slateDescription = slateDescription
            slate.recommendations = NSOrderedSet(array: recommendations)

            var i = 1
            slate.recommendations?.forEach { rec in
                var rec = rec as! Recommendation
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
        item: Item
    ) throws -> Recommendation {
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
        item: Item,
        imageURL: URL? = nil,
        title: String? = nil,
        excerpt: String?  = nil,
        analyticsID: String = ""
    ) -> Recommendation {
        backgroundContext.performAndWait {
            let recommendation: Recommendation = Recommendation(context: backgroundContext, remoteID: remoteID, analyticsID: analyticsID)
            recommendation.item = item
            recommendation.title = title
            recommendation.excerpt = excerpt
            recommendation.imageURL = imageURL
            recommendation.analyticsID = analyticsID
            return recommendation
        }
    }
}

// MARK: - SharedWithYou
extension Space {
    @discardableResult
    func createSharedWithYouHighlight(
        item: Item,
        sortOrder: Int32 = 1
    ) throws -> SharedWithYouHighlight {
        try backgroundContext.performAndWait {
            let sharedWithYouHighlight = buildSharedWithYouHighlight(
                item: item,
                sortOrder: sortOrder
            )
            try backgroundContext.save()
            return sharedWithYouHighlight
        }
    }

    @discardableResult
    func buildSharedWithYouHighlight(
        item: Item,
        sortOrder: Int32
    ) -> SharedWithYouHighlight {
        backgroundContext.performAndWait {
            return SharedWithYouHighlight(context: backgroundContext, url: item.givenURL, sortOrder: sortOrder, item: item)
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
    ) -> SyndicatedArticle {
        backgroundContext.performAndWait {
            let syndicatedArticle: SyndicatedArticle = SyndicatedArticle(context: backgroundContext)
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
        item: Item? = nil
    ) -> Image {
        return backgroundContext.performAndWait {
            let image: Image = Image(context: backgroundContext)
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
        item: Item? = nil
    ) throws -> Image {
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
