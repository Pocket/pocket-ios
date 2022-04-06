// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

class Space {
    private let container: PersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(container: PersistentContainer) {
        self.container = container
    }

    func managedObjectID(forURL url: URL) -> NSManagedObjectID? {
        container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
    }

    func fetchSavedItem(byRemoteID remoteID: String) throws -> SavedItem? {
        let request = Requests.fetchSavedItem(byRemoteID: remoteID)
        return try context.fetch(request).first
    }

    func fetchSavedItem(byRemoteItemID remoteItemID: String) throws -> SavedItem? {
        let request = Requests.fetchSavedItem(byRemoteItemID: remoteItemID)
        return try context.fetch(request).first
    }

    func fetchSavedItem(byURL url: URL) throws -> SavedItem? {
        let request = Requests.fetchSavedItem(byURL: url)
        return try context.fetch(request).first
    }

    func fetchSavedItems() throws -> [SavedItem] {
        let request = Requests.fetchSavedItems()
        let results = try context.fetch(request)
        return results
    }

    func fetchArchivedItems() throws -> [SavedItem] {
        return try fetch(Requests.fetchArchivedItems())
    }

    func fetchAllSavedItems() throws -> [SavedItem] {
        return try fetch(Requests.fetchAllSavedItems())
    }
    
    func fetchOrCreateSavedItem(byRemoteID itemID: String) throws -> SavedItem {
        try fetchSavedItem(byRemoteID: itemID) ?? new()
    }

    func fetchPersistentSyncTasks() throws -> [PersistentSyncTask] {
        return try fetch(Requests.fetchPersistentSyncTasks())
    }

    func fetchSavedItemUpdatedNotifications() throws -> [SavedItemUpdatedNotification] {
        return try fetch(Requests.fetchSavedItemUpdatedNotifications())
    }

    func fetchUnresolvedSavedItems() throws -> [UnresolvedSavedItem] {
        return try fetch(Requests.fetchUnresolvedSavedItems())
    }

    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] {
        try context.fetch(request)
    }

    func new<T: NSManagedObject>() -> T {
        return T(context: context)
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }

    func delete(_ objects: [NSManagedObject]) {
        objects.forEach(context.delete(_:))
    }

    func save() throws {
        try context.obtainPermanentIDs(for: Array(context.insertedObjects))
        try context.save()
    }
    
    func clear() throws {
        let context = container.viewContext
        for entity in container.managedObjectModel.entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
    }

    func makeItemsController() -> NSFetchedResultsController<SavedItem> {
        NSFetchedResultsController(
            fetchRequest: Requests.fetchSavedItems(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeArchivedItemsController() -> NSFetchedResultsController<SavedItem> {
        NSFetchedResultsController(
            fetchRequest: Requests.fetchArchivedItems(),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func object<T: NSManagedObject>(with id: NSManagedObjectID) -> T? {
        context.object(with: id) as? T
    }

    func refresh(_ object: NSManagedObject, mergeChanges: Bool) {
        context.refresh(object, mergeChanges: mergeChanges)
    }
}
