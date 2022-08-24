// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

public enum Requests {
    public static func fetchSavedItems(limit: Int? = nil) -> NSFetchRequest<SavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = Predicates.savedItems()
        if let limit = limit {
            request.fetchLimit = limit
        }
        return request
    }

    public static func fetchArchivedItems(filters: [NSPredicate] = []) -> NSFetchRequest<SavedItem> {
        let request: NSFetchRequest<SavedItem> = SavedItem.fetchRequest()
        request.predicate = Predicates.archivedItems(filters: filters)

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavedItem.archivedAt, ascending: false),
            NSSortDescriptor(key: "item.title", ascending: true)
        ]

        return request
    }

    public static func fetchAllSavedItems() -> NSFetchRequest<SavedItem> {
        let request: NSFetchRequest<SavedItem> = SavedItem.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavedItem.createdAt, ascending: false),
            NSSortDescriptor(key: "item.title", ascending: true)
        ]

        return request
    }

    public static func fetchSavedItem(byRemoteID remoteID: String) -> NSFetchRequest<SavedItem> {
        let request = SavedItem.fetchRequest()
        request.predicate = NSPredicate(format: "remoteID = %@", remoteID)
        request.fetchLimit = 1
        return request
    }

    public static func fetchSavedItem(byRemoteItemID remoteItemID: String) -> NSFetchRequest<SavedItem> {
        let request = SavedItem.fetchRequest()
        request.predicate = NSPredicate(format: "item.remoteID = %@", remoteItemID)
        request.fetchLimit = 1
        return request
    }

    public static func fetchSavedItem(byURL url: URL) -> NSFetchRequest<SavedItem> {
        let request = SavedItem.fetchRequest()
        request.predicate = NSPredicate(format: "url.absoluteString = %@", url.absoluteString)
        request.fetchLimit = 1
        return request
    }

    public static func fetchPersistentSyncTasks() -> NSFetchRequest<PersistentSyncTask> {
        let request = PersistentSyncTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PersistentSyncTask.createdAt, ascending: true)]

        return request
    }

    public static func fetchSavedItemUpdatedNotifications() -> NSFetchRequest<SavedItemUpdatedNotification> {
        return SavedItemUpdatedNotification.fetchRequest()
    }

    public static func fetchUnresolvedSavedItems() -> NSFetchRequest<UnresolvedSavedItem> {
        UnresolvedSavedItem.fetchRequest()
    }

    public static func fetchSlateLineups() -> NSFetchRequest<SlateLineup> {
        SlateLineup.fetchRequest()
    }

    public static func fetchSlateLineup(byID id: String) -> NSFetchRequest<SlateLineup> {
        let request = Self.fetchSlateLineups()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return request
    }

    public static func fetchSlates() -> NSFetchRequest<Slate> {
        Slate.fetchRequest()
    }

    public static func fetchSlate(byID id: String) -> NSFetchRequest<Slate> {
        let request = Self.fetchSlates()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return request
    }

    public static func fetchRecommendations() -> NSFetchRequest<Recommendation> {
        Recommendation.fetchRequest()
    }

    public static func fetchItems() -> NSFetchRequest<Item> {
        Item.fetchRequest()
    }

    public static func fetchItem(byRemoteID id: String) -> NSFetchRequest<Item> {
        let request = self.fetchItems()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return request
    }
    
    public static func fetchTags() -> NSFetchRequest<Tag> {
        Tag.fetchRequest()
    }
    
    public static func fetchTag(byName name: String) -> NSFetchRequest<Tag> {
        let request = self.fetchTags()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        return request
    }

    public static func fetchUnsavedItems() -> NSFetchRequest<Item> {
        let request = self.fetchItems()
        request.predicate = NSPredicate(format: "savedItem = nil")
        return request
    }

    public static func fetchUndownloadedImages() -> NSFetchRequest<Image> {
        let request = Image.fetchRequest()
        request.predicate = NSPredicate(format: "isDownloaded = NO")
        return request
    }

    public static func fetchSavedItem(for item: Item) -> NSFetchRequest<SavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = Predicates.savedItems(filters: [NSPredicate(format: "item = %@", item)])

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
}
