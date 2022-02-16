// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData


public enum Requests {
    public static func fetchSavedItems() -> NSFetchRequest<SavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = Predicates.savedItems()

        return request
    }

    public static func fetchArchivedItems() -> NSFetchRequest<SavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = Predicates.archivedItems()

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

    public static func fetchPersistentSyncTasks() -> NSFetchRequest<PersistentSyncTask> {
        let request = PersistentSyncTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PersistentSyncTask.createdAt, ascending: true)]

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
