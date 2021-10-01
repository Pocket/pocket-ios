// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData


public enum Requests {
    public static func fetchSavedItems() -> NSFetchRequest<SavedItem> {
        let request = fetchAllSavedItems()
        request.predicate = NSPredicate(format: "isArchived = false && deletedAt = nil")

        return request
    }

    public static func fetchAllSavedItems() -> NSFetchRequest<SavedItem> {
        let request: NSFetchRequest<SavedItem> = SavedItem.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavedItem.timestamp, ascending: false),
            NSSortDescriptor(keyPath: \SavedItem.title, ascending: true)
        ]

        return request
    }
    
    public static func fetchSavedItem(byRemoteID remoteID: String) -> NSFetchRequest<SavedItem> {
        let request = SavedItem.fetchRequest()
        request.predicate = NSPredicate(format: "itemID = %@", remoteID)
        request.fetchLimit = 1
        return request
    }
}
