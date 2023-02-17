// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

public class Space {
    let context: NSManagedObjectContext

    required public init(context: NSManagedObjectContext) {
        self.context = context
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    func managedObjectID(forURL url: URL) -> NSManagedObjectID? {
        context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
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

    func fetchSavedItems(bySearchTerm searchTerm: String, userPremium isPremium: Bool) throws -> [SavedItem]? {
        let request = Requests.fetchSavedItems(bySearchTerm: searchTerm, userPremium: isPremium)
        return try context.fetch(request)
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

    func fetchPersistentSyncTasks() throws -> [PersistentSyncTask] {
        return try fetch(Requests.fetchPersistentSyncTasks())
    }

    func fetchSavedItemUpdatedNotifications() throws -> [SavedItemUpdatedNotification] {
        return try fetch(Requests.fetchSavedItemUpdatedNotifications())
    }

    func fetchUnresolvedSavedItems() throws -> [UnresolvedSavedItem] {
        return try fetch(Requests.fetchUnresolvedSavedItems())
    }

    func fetchSlateLineups() throws -> [SlateLineup] {
        return try fetch(Requests.fetchSlateLineups())
    }

    func fetchSlateLineup(byRemoteID id: String) throws -> SlateLineup? {
        return try fetch(Requests.fetchSlateLineup(byID: id)).first
    }

    func fetchSlates() throws -> [Slate] {
        return try fetch(Requests.fetchSlates())
    }

    func fetchSlate(byRemoteID id: String) throws -> Slate? {
        let request = Requests.fetchSlates()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return try fetch(request).first
    }

    func fetchRecommendations() throws -> [Recommendation] {
        return try fetch(Requests.fetchRecommendations())
    }

    func fetchRecommendation(byRemoteID id: String) throws -> Recommendation? {
        let request = Requests.fetchRecommendations()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return try fetch(request).first
    }

    func fetchItems() throws -> [Item] {
        return try fetch(Requests.fetchItems())
    }

    func fetchItem(byRemoteID id: String) throws -> Item? {
        return try fetch(Requests.fetchItem(byRemoteID: id)).first
    }

    func fetchItem(byURL url: URL) throws -> Item? {
        return try fetch(Requests.fetchItem(byURL: url)).first
    }

    func fetchSyndicatedArticle(byItemId id: String) throws -> SyndicatedArticle? {
        return try fetch(Requests.fetchSyndicatedArticle(byItemId: id)).first
    }

    func fetchAllTags() throws -> [Tag] {
        return try fetch(Requests.fetchTags())
    }

    func fetchTags(isArchived: Bool) throws -> [Tag] {
        if isArchived {
            return try fetch(Requests.fetchArchivedTags())
        } else {
            return try fetch(Requests.fetchSavedTags())
        }
    }

    func fetchOrCreateTag(byName name: String) -> Tag {
        let fetchRequest = Requests.fetchTag(byName: name)
        fetchRequest.fetchLimit = 1
        let fetchedTag = (try? fetch(fetchRequest).first) ?? Tag(context: context)
        guard fetchedTag.name == nil else { return fetchedTag }
        fetchedTag.name = name
        return fetchedTag
    }

    func fetchTag(byID id: String) throws -> Tag? {
        try fetch(Requests.fetchTag(byID: id)).first
    }

    func retrieveTags(excluding tags: [String]) throws -> [Tag] {
        return try fetch(Requests.fetchTags(excluding: tags))
    }

    func deleteTag(byID id: String) throws {
        let fetchRequest = Requests.fetchTag(byID: id)
        fetchRequest.fetchLimit = 1
        let tag = try context.fetch(fetchRequest)
        delete(tag)
    }

    func fetchUnsavedItems() throws -> [Item] {
        return try fetch(Requests.fetchUnsavedItems())
    }

    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] {
        try context.fetch(request)
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }

    func delete(_ objects: [NSManagedObject]) {
        objects.forEach(context.delete(_:))
    }

    func deleteUnsavedItems() throws {
        try delete(fetchUnsavedItems())
    }

    func save() throws {
        try context.obtainPermanentIDs(for: Array(context.insertedObjects))
        try context.save()
    }

    func clear() throws {
        try context.performAndWait {
            guard let objectModel = context.persistentStoreCoordinator?.managedObjectModel else {
                return
            }

            for entity in objectModel.entities {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try context.execute(deleteRequest)
            }

            context.reset()
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

    func makeArchivedItemsController(filters: [NSPredicate] = []) -> NSFetchedResultsController<SavedItem> {
        NSFetchedResultsController(
            fetchRequest: Requests.fetchArchivedItems(filters: filters),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeSlateLineupController() -> NSFetchedResultsController<SlateLineup> {
        let request = Requests.fetchSlateLineups()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "requestID", ascending: true)]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeSlateController(byID id: String) -> NSFetchedResultsController<Slate> {
        let request = Requests.fetchSlate(byID: id)
        request.sortDescriptors = [NSSortDescriptor(key: "remoteID", ascending: true)]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeUndownloadedImagesController() -> NSFetchedResultsController<Image> {
        let request = Requests.fetchUndownloadedImages()
        request.sortDescriptors = [NSSortDescriptor(key: "source.absoluteString", ascending: true)]
        return NSFetchedResultsController(
            fetchRequest: request,
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

    func batchDeleteArchivedItems() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SavedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isArchived = 1")

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let deleteResult = try context.execute(deleteRequest) as? NSBatchDeleteResult
        if let deletedItemIDs = deleteResult?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: deletedItemIDs],
                into: [context]
            )
        }
    }

    func batchDeleteOrphanedSlates() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Slate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slateLineup = NULL")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try context.execute(deleteRequest)
    }

    func batchDeleteOrphanedItems() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recommendation = NULL && savedItem = NULL")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try context.execute(deleteRequest)
    }
}
