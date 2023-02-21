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
        tags: [Tag]? = nil,
        item: Item? = nil
    ) throws -> SavedItem {
        try context.performAndWait {
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
        tags: [Tag]? = nil,
        item: Item? = nil
    ) -> SavedItem {
        context.performAndWait {
            let savedItem: SavedItem = SavedItem(context: context, url: URL(string: url)!)
            savedItem.remoteID = remoteID
            savedItem.isFavorite = isFavorite
            savedItem.isArchived = isArchived
            savedItem.createdAt = createdAt
            savedItem.archivedAt = archivedAt
            savedItem.cursor = cursor
            savedItem.tags = NSOrderedSet(array: tags ?? [])
            savedItem.item = item ?? Item(context: context, givenURL: URL(string: url)!, remoteID: remoteID)

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
        itemID: String? = nil,
        publisherName: String? = nil,
        title: String? = nil,
        item: Item? = nil
    ) throws -> SyndicatedArticle {
        try context.performAndWait {
            let sydnicatedArticle = buildSyndicatedArticle(
                excerpt: excerpt,
                imageURL: imageURL,
                itemID: itemID,
                publisherName: publisherName,
                title: title,
                item: item
            )
            try save()

            return sydnicatedArticle
        }
    }

    @discardableResult
    func buildSyndicatedArticle(
        excerpt: String? = nil,
        imageURL: URL? = nil,
        itemID: String? = nil,
        publisherName: String? = nil,
        title: String? = nil,
        item: Item? = nil
    ) -> SyndicatedArticle {
        context.performAndWait {
            let sydnicatedArticle: SyndicatedArticle = SyndicatedArticle(context: context)
            sydnicatedArticle.excerpt = excerpt
            sydnicatedArticle.imageURL = imageURL
            sydnicatedArticle.itemID = itemID
            sydnicatedArticle.publisherName = publisherName
            sydnicatedArticle.title = title
            sydnicatedArticle.item = item
            return sydnicatedArticle
        }
    }
}



// MARK: - Item
extension Space {
    @discardableResult
    func createItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: URL = URL(string: "https://example.com/items/item-1")!,
        isArticle: Bool = true,
        syndicatedArticle: SyndicatedArticle? = nil
    ) throws -> Item {
        try context.performAndWait {
            let item = buildItem(
                remoteID: remoteID,
                title: title,
                givenURL: givenURL,
                isArticle: isArticle,
                syndicatedArticle: syndicatedArticle
            )
            try save()

            return item
        }
    }

    @discardableResult
    func buildItem(
        remoteID: String = "item-1",
        title: String = "Item 1",
        givenURL: URL? = URL(string: "https://example.com/items/item-1"),
        resolvedURL: URL? = nil,
        isArticle: Bool = true,
        syndicatedArticle: SyndicatedArticle? = nil
    ) -> Item {
        var url = givenURL
        if url == nil {
            url = URL(string: "https://example.com/items/item-1")
        }

        return context.performAndWait {
            let item: Item = Item(context: context, givenURL: url!, remoteID: remoteID)
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
        slates: [Slate] = []
    ) throws -> SlateLineup {
        try context.performAndWait {
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
        context.performAndWait {
            let lineup: SlateLineup = SlateLineup(context: context, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
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
        try context.performAndWait {
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
        context.performAndWait {
            let slate: Slate = Slate(context: context, remoteID: remoteID, expermimentID: experimentID, requestID: requestID)
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
        item: Item? = nil
    ) throws -> Recommendation {
        try context.performAndWait {
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
        item: Item? = nil
    ) -> Recommendation {
        context.performAndWait {
            let recommendation: Recommendation = Recommendation(context: context, remoteID: remoteID)
            recommendation.item = item

            return recommendation
        }
    }
}
