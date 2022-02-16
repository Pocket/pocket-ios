// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

class Space {
    private let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(container: NSPersistentContainer) {
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

    func fetchSavedItems() throws -> [SavedItem] {
        let request = Requests.fetchSavedItems()
        let results = try context.fetch(request)
        return results
    }

    func fetchArchivedItems() throws -> [SavedItem] {
        let request = Requests.fetchArchivedItems()
        return try context.fetch(request)
    }

    func fetchAllSavedItems() throws -> [SavedItem] {
        return try context.fetch(Requests.fetchAllSavedItems())
    }
    
    func fetchOrCreateSavedItem(byRemoteID itemID: String) throws -> SavedItem {
        try fetchSavedItem(byRemoteID: itemID) ?? new()
    }

    func fetchPersistentSyncTasks() throws -> [PersistentSyncTask] {
        return try context.fetch(Requests.fetchPersistentSyncTasks())
    }

    func new<T: NSManagedObject>() -> T {
        return T(context: context)
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
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

    func object<T: NSManagedObject>(with id: NSManagedObjectID) -> T? {
        context.object(with: id) as? T
    }
}
