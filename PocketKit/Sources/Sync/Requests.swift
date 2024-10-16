// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

public enum Requests {
    public static func fetchSavedItems(limit: Int? = nil) -> NSFetchRequest<CDSavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = Predicates.savedItems()
        if let limit = limit {
            request.fetchLimit = limit
        }
        return request
    }

    public static func fetchArchivedItems(filters: [NSPredicate] = []) -> NSFetchRequest<CDSavedItem> {
        let request: NSFetchRequest<CDSavedItem> = CDSavedItem.fetchRequest()
        request.predicate = Predicates.archivedItems(filters: filters)

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDSavedItem.archivedAt, ascending: false),
            NSSortDescriptor(key: "item.title", ascending: true)
        ]

        return request
    }

    public static func fetchAllSavedItems() -> NSFetchRequest<CDSavedItem> {
        let request: NSFetchRequest<CDSavedItem> = CDSavedItem.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDSavedItem.createdAt, ascending: false),
            NSSortDescriptor(key: "item.title", ascending: true)
        ]

        return request
    }

    public static func fetchSavedItem(byURL url: String) -> NSFetchRequest<CDSavedItem> {
        let request = CDSavedItem.fetchRequest()
        request.predicate = NSPredicate(format: "url = %@", url as CVarArg)
        request.fetchLimit = 1
        return request
    }

    public static func fetchSavedItems(bySearchTerm searchTerm: String, userPremium isPremium: Bool) -> NSFetchRequest<CDSavedItem> {
        let request = CDSavedItem.fetchRequest()
        let urlPredicate = NSPredicate(format: "url CONTAINS %@", searchTerm)
        let titlePredicate = NSPredicate(format: "item.title CONTAINS %@", searchTerm)
        let urlTitlePredicate = NSCompoundPredicate(type: .or, subpredicates: [urlPredicate, titlePredicate])
        let unarchivedPredicate = NSPredicate(format: "isArchived = false")
        var allPredicate = NSCompoundPredicate(type: .and, subpredicates: [urlTitlePredicate, unarchivedPredicate])
        if isPremium {
            let tagsPredicate = NSPredicate(format: "%@ IN tags.name", searchTerm)
            let premiumPredicate = NSCompoundPredicate(type: .or, subpredicates: [urlTitlePredicate, tagsPredicate])
            allPredicate = NSCompoundPredicate(type: .and, subpredicates: [premiumPredicate, unarchivedPredicate])
        }
        request.predicate = allPredicate
        return request
    }

    public static func fetchPersistentSyncTasks() -> NSFetchRequest<CDPersistentSyncTask> {
        let request = CDPersistentSyncTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDPersistentSyncTask.createdAt, ascending: true)]

        return request
    }

    public static func fetchSavedItemUpdatedNotifications() -> NSFetchRequest<CDSavedItemUpdatedNotification> {
        return CDSavedItemUpdatedNotification.fetchRequest()
    }

    public static func fetchUnresolvedSavedItems() -> NSFetchRequest<CDUnresolvedSavedItem> {
        CDUnresolvedSavedItem.fetchRequest()
    }

    public static func fetchSlateLineups() -> NSFetchRequest<CDSlateLineup> {
        CDSlateLineup.fetchRequest()
    }

    public static func fetchSlateLineup(byID id: String) -> NSFetchRequest<CDSlateLineup> {
        let request = Self.fetchSlateLineups()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return request
    }

    public static func fetchSlates() -> NSFetchRequest<CDSlate> {
        CDSlate.fetchRequest()
    }

    public static func fetchRecomendations() -> RichFetchRequest<CDRecommendation> {
        let request = RichFetchRequest<CDRecommendation>(entityName: "Recommendation")
        // We only search for valid recommendations without specifying a lineup, since the lineup will be only 1 (from unified home)
        request.predicate = NSPredicate(format: "item != NULL")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDRecommendation.slate?.sortIndex, ascending: true),
            NSSortDescriptor(keyPath: \CDRecommendation.sortIndex, ascending: true),
        ]
        request.relationshipKeyPathsForRefreshing = [
            #keyPath(CDRecommendation.slate.sortIndex),
            // Reload the cell when the image finishes downloading. Kingfisher has a bug where the cell is not always reloaded with the image.
            #keyPath(CDRecommendation.image.isDownloaded),
            #keyPath(CDRecommendation.item.title),
            #keyPath(CDRecommendation.item.savedItem.archivedAt),
            #keyPath(CDRecommendation.item.savedItem.isFavorite),
            #keyPath(CDRecommendation.item.savedItem.createdAt),
        ]
        return request
    }

    public static func fetchSlate(byID id: String) -> NSFetchRequest<CDSlate> {
        let request = Self.fetchSlates()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return request
    }

    public static func fetchRecommendations() -> NSFetchRequest<CDRecommendation> {
        CDRecommendation.fetchRequest()
    }

    public static func fetchItems() -> NSFetchRequest<CDItem> {
        CDItem.fetchRequest()
    }

    public static func fetchSyndicatedArticles() -> NSFetchRequest<CDSyndicatedArticle> {
        CDSyndicatedArticle.fetchRequest()
    }

    public static func fetchSyndicatedArticle(byItemId id: String) -> NSFetchRequest<CDSyndicatedArticle> {
        let request = self.fetchSyndicatedArticles()
        request.predicate = NSPredicate(format: "itemID = %@", id)
        request.fetchLimit = 1
        return request
    }

    public static func fetchCollection(by slug: String) -> NSFetchRequest<CDCollection> {
        let request = CDCollection.fetchRequest()
        request.predicate = NSPredicate(format: "slug = %@", slug)
        request.fetchLimit = 1
        return request
    }

    public static func fetchCollectionAuthor(by name: String) -> NSFetchRequest<CDCollectionAuthor> {
        let request = CDCollectionAuthor.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        return request
    }

    public static func fetchCollectionAuthors(by slug: String) -> NSFetchRequest<CDCollectionAuthor> {
        let request = CDCollectionAuthor.fetchRequest()
        request.predicate = NSPredicate(format: "collection.slug = %@", slug)
        return request
    }

    public static func fetchCollectionStory(by url: String) -> NSFetchRequest<CDCollectionStory> {
        let request = CDCollectionStory.fetchRequest()
        request.predicate = NSPredicate(format: "url = %@", url)
        request.fetchLimit = 1
        return request
    }

    public static func fetchCollectionStories(by slug: String) -> RichFetchRequest<CDCollectionStory> {
        let request = RichFetchRequest<CDCollectionStory>(entityName: "CollectionStory")
        request.predicate = NSPredicate(format: "collection.slug = %@", slug)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDCollectionStory.sortOrder, ascending: true)]

        request.relationshipKeyPathsForRefreshing = [
            #keyPath(CDCollectionStory.item.savedItem.archivedAt),
            #keyPath(CDCollectionStory.item.savedItem.isFavorite),
            #keyPath(CDCollectionStory.item.savedItem.createdAt),
        ]

        return request
    }

    public static func fetchHighlight(by ID: String) -> NSFetchRequest<CDHighlight> {
        let request = CDHighlight.fetchRequest()
        request.predicate = NSPredicate(format: "remoteID = %@", ID)
        request.fetchLimit = 1
        return request
    }

    public static func fetchHighlights(by savedItemUrl: String) -> NSFetchRequest<CDHighlight> {
        let request = CDHighlight.fetchRequest()
        request.predicate = NSPredicate(format: "savedItem.url = %@", savedItemUrl)
        return request
    }

    public static func fetchTags() -> NSFetchRequest<CDTag> {
        return CDTag.fetchRequest()
    }

    public static func fetchSavedTags() -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        request.predicate = NSPredicate(format: "ANY savedItems.isArchived = false")
        return request
    }

    public static func fetchArchivedTags() -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        request.predicate = NSPredicate(format: "ANY savedItems.isArchived = true")
        return request
    }

    public static func fetchTag(byName name: String) -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        return request
    }

    public static func fetchTag(byID id: String) -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return request
    }

    public static func fetchTagsWithNoSavedItems() -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        request.predicate = NSPredicate(format: "savedItems.@count = 0")
        return request
    }

    public static func fetchTags(excluding tags: [String]) -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        request.predicate = NSPredicate(format: "NOT (self.name IN %@)", tags)
        return request
    }

    public static func filterTags(with input: String, excluding tags: [String]) -> NSFetchRequest<CDTag> {
        let request = fetchTags()
        let filterPredicate = NSPredicate(format: "name BEGINSWITH %@", input)
        let excludePredicate = NSPredicate(format: "NOT (self.name IN %@)", tags)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, excludePredicate])
        return request
    }

    public static func fetchUnsavedItems() -> NSFetchRequest<CDItem> {
        let request = self.fetchItems()
        request.predicate = NSPredicate(format: "savedItem = nil")
        return request
    }

    public static func fetchUndownloadedImages() -> NSFetchRequest<CDImage> {
        return CDImage.fetchRequest()
    }

    public static func fetchSavedItem(for item: CDItem) -> NSFetchRequest<CDSavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = Predicates.savedItems(filters: [NSPredicate(format: "item = %@", item)])

        return request
    }

    public static func fetchItem(byURL url: String) -> NSFetchRequest<CDItem> {
        let request = fetchItems()
        request.predicate = NSPredicate(format: "givenURL = %@", url)
        request.fetchLimit = 1
        return request
    }

    public static func fetchFeatureFlags() -> NSFetchRequest<CDFeatureFlag> {
        CDFeatureFlag.fetchRequest()
    }

    public static func fetchFeatureFlag(byName name: String) -> NSFetchRequest<CDFeatureFlag> {
        let request = fetchFeatureFlags()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        return request
    }
    public static func fetchSharedWithYouItem() -> NSFetchRequest<CDSharedWithYouItem> {
        CDSharedWithYouItem.fetchRequest()
    }

    public static func fetchAllSharedWithYouItems() -> NSFetchRequest<CDSharedWithYouItem> {
        let request: NSFetchRequest<CDSharedWithYouItem> = CDSharedWithYouItem.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDSharedWithYouItem.sortOrder, ascending: true),
            NSSortDescriptor(key: "item.title", ascending: true)
        ]

        return request
    }

    public static func fetchSharedWithYouItems(limit: Int? = nil) -> RichFetchRequest<CDSharedWithYouItem> {
        let request = RichFetchRequest<CDSharedWithYouItem>(entityName: "SharedWithYouItem")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDSharedWithYouItem.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \CDSharedWithYouItem.item.title, ascending: true)
        ]
        request.relationshipKeyPathsForRefreshing = [
            #keyPath(CDSharedWithYouItem.item.title),
            #keyPath(CDSharedWithYouItem.item.savedItem.archivedAt),
            #keyPath(CDSharedWithYouItem.item.savedItem.isFavorite),
            #keyPath(CDSharedWithYouItem.item.savedItem.createdAt),
        ]
        if let limit = limit {
            request.fetchLimit = limit
        }
        return request
    }
}

public enum Predicates {
    public static func savedItems(filters: [NSPredicate] = []) -> NSPredicate {
        let predicates = filters + [NSPredicate(format: "isArchived = false && deletedAt = nil")]
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    public static func archivedItems(filters: [NSPredicate] = []) -> NSPredicate {
        let predicates = filters + [NSPredicate(format: "isArchived = true && deletedAt = nil")]
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    public static func allItems(filters: [NSPredicate] = []) -> NSPredicate {
        let predicates = filters + [NSPredicate(format: "deletedAt = nil")]
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
