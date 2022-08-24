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
        tags: [String]? = nil,
        item: Item? = nil
    ) -> SavedItem {
        context.performAndWait {
            let savedItem: SavedItem = new()
            let tags: [Tag]? = tags?.map { tag -> Tag in
                let newTag: Tag = new()
                newTag.name = tag
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
            savedItem.item = item ?? new()

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
        givenURL: URL? = URL(string: "https://example.com/items/item-1"),
        isArticle: Bool = true
    ) throws -> Item {
        try context.performAndWait {
            let item = buildItem(
                remoteID: remoteID,
                title: title,
                givenURL: givenURL,
                isArticle: isArticle
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
        isArticle: Bool = true
    ) -> Item {
        context.performAndWait {
            let item: Item = new()
            item.remoteID = remoteID
            item.title = title
            item.givenURL = givenURL
            item.resolvedURL = resolvedURL
            item.isArticle = isArticle

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
            let lineup: SlateLineup = new()
            lineup.remoteID = remoteID
            lineup.requestID = requestID
            lineup.experimentID = experimentID
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
            let slate: Slate = new()
            slate.experimentID = experimentID
            slate.remoteID = remoteID
            slate.name = name
            slate.requestID = requestID
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
            let recommendation: Recommendation = new()
            recommendation.remoteID = remoteID
            recommendation.item = item

            return recommendation
        }
    }
}
