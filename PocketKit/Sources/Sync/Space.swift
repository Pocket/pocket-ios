// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
/// Handles all dabatabase operations within Pocket app.
/// This should only ever be used and injected into the PocketSource class.
/// Pocket Source should proxy all requests to this class and handle the updating of data.
public class Space {
    let backgroundContext: NSManagedObjectContext
    let viewContext: NSManagedObjectContext

    required public init(backgroundContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) {
        self.backgroundContext = backgroundContext
        self.viewContext = viewContext
    }

    // MARK: base methods
    func managedObjectID(forURL url: URL) -> NSManagedObjectID? {
        backgroundContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    }

    /// Performs the given request on the specified context. If context is nil, the default `backgroundContext` is used
    /// - Parameters:
    ///   - request: the given request
    ///   - context: the specified context, or nil
    /// - Returns: Fetch results
    func fetch<T>(_ request: NSFetchRequest<T>, context: NSManagedObjectContext? = nil) throws -> [T] {
        let context = context ?? backgroundContext
        return try context.performAndWait { try context.fetch(request) }
    }

    func delete(_ object: NSManagedObject) {
        backgroundContext.performAndWait {
            guard let object = backgroundObject(with: object.objectID) else {
                return
            }
            backgroundContext.delete(object)
        }
    }

    func delete(_ byIDs: [NSManagedObjectID], for entity: NSEntityDescription) throws {
        try backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            fetchRequest.predicate = NSPredicate(format: "SELF IN %@", byIDs)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try backgroundContext.execute(deleteRequest)
            try backgroundContext.save()
        }
    }

    func delete(_ objects: [NSManagedObject]) {
        backgroundContext.performAndWait { objects.compactMap({ backgroundObject(with: $0.objectID) }).forEach(backgroundContext.delete(_:)) }
    }

    func save() throws {
        try backgroundContext.performAndWait {
            //try backgroundContext.obtainPermanentIDs(for: Array(backgroundContext.insertedObjects))
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
        }
    }

    func performAndWait<T>(_ block: () throws -> T) rethrows -> T {
        return try backgroundContext.performAndWait(block)
    }

    func perform<T>(schedule: NSManagedObjectContext.ScheduledTaskType = .immediate, _ block: @escaping () throws -> T) async rethrows -> T {
        return try await backgroundContext.perform(schedule: schedule, block)
    }

    func clear() throws {
        try backgroundContext.performAndWait {
            guard let objectModel = backgroundContext.persistentStoreCoordinator?.managedObjectModel else {
                return
            }

            for entity in objectModel.entities {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try backgroundContext.execute(deleteRequest)
            }
            backgroundContext.reset()
        }
    }

    func backgroundObject<T: NSManagedObject>(with id: NSManagedObjectID) -> T? {
        backgroundContext.performAndWait {
            backgroundContext.object(with: id) as? T
        }
    }

    func viewObject<T: NSManagedObject>(with id: NSManagedObjectID) -> T? {
        viewContext.performAndWait {
            viewContext.object(with: id) as? T
        }
    }

    func backgroundRefresh(_ object: NSManagedObject, mergeChanges: Bool) {
        backgroundContext.performAndWait {
            backgroundContext.refresh(object, mergeChanges: mergeChanges)
        }
    }

    func viewRefresh(_ object: NSManagedObject, mergeChanges: Bool) {
        viewContext.performAndWait {
            viewContext.refresh(object, mergeChanges: mergeChanges)
        }
    }
}

// MARK: Image
extension Space {
    func makeImagesController() -> NSFetchedResultsController<Image> {
        let request = Requests.fetchUndownloadedImages()
        request.sortDescriptors = [NSSortDescriptor(key: "source.absoluteString", ascending: true)]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: backgroundContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}

// MARK: Item
extension Space {
    func fetchItems() throws -> [Item] {
        return try fetch(Requests.fetchItems())
    }

    func fetchItem(byRemoteID id: String, context: NSManagedObjectContext? = nil) throws -> Item? {
        return try fetch(Requests.fetchItem(byRemoteID: id), context: context).first
    }

    func fetchItem(byURL url: URL) throws -> Item? {
        return try fetch(Requests.fetchItem(byURL: url)).first
    }

    func deleteUnsavedItems() throws {
        try delete(fetchUnsavedItems())
    }

    func fetchUnsavedItems() throws -> [Item] {
        return try fetch(Requests.fetchUnsavedItems())
    }

    func batchDeleteOrphanedItems() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recommendation = NULL && savedItem = NULL")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        _ = try backgroundContext.performAndWait {
            try backgroundContext.execute(deleteRequest)
        }
    }
}

// MARK: Recommendation
extension Space {
    func fetchRecommendations(context: NSManagedObjectContext? = nil) throws -> [Recommendation] {
        return try fetch(Requests.fetchRecommendations(), context: context)
    }

    func fetchRecommendation(byRemoteID id: String, context: NSManagedObjectContext? = nil) throws -> Recommendation? {
        let request = Requests.fetchRecommendations()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return try fetch(request, context: context).first
    }

    func makeRecomendationsSlateLineupController(by lineupIdentifier: String) -> RichFetchedResultsController<Recommendation> {
        RichFetchedResultsController(
            fetchRequest: Requests.fetchRecomendations(by: lineupIdentifier),
            managedObjectContext: viewContext,
            sectionNameKeyPath: "slate.sortIndex",
            cacheName: nil
        )
    }
}

// MARK: SavedItem
extension Space {
    func fetchSavedItem(byRemoteID remoteID: String) throws -> SavedItem? {
        return try fetch(Requests.fetchSavedItem(byRemoteID: remoteID)).first
    }

    func fetchSavedItem(byRemoteItemID remoteItemID: String) throws -> SavedItem? {
        return try fetch(Requests.fetchSavedItem(byRemoteItemID: remoteItemID)).first
    }

    func fetchSavedItem(byURL url: URL) throws -> SavedItem? {
        return try fetch(Requests.fetchSavedItem(byURL: url)).first
    }

    func fetchSavedItems(bySearchTerm searchTerm: String, userPremium isPremium: Bool) throws -> [SavedItem]? {
        return try fetch(Requests.fetchSavedItems(bySearchTerm: searchTerm, userPremium: isPremium))
    }

    func fetchSavedItems() throws -> [SavedItem] {
        return try fetch(Requests.fetchSavedItems())
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

    func makeItemsController() -> NSFetchedResultsController<SavedItem> {
        NSFetchedResultsController(
            fetchRequest: Requests.fetchSavedItems(),
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeRecentSavesController(limit: Int) -> NSFetchedResultsController<SavedItem> {
        NSFetchedResultsController(
            fetchRequest: Requests.fetchSavedItems(limit: limit),
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeArchivedItemsController(filters: [NSPredicate] = []) -> NSFetchedResultsController<SavedItem> {
        NSFetchedResultsController(
            fetchRequest: Requests.fetchArchivedItems(filters: filters),
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}

// MARK: Slate/SlateLineUp
extension Space {
    func fetchSlateLineups() throws -> [SlateLineup] {
        return try fetch(Requests.fetchSlateLineups())
    }

    func fetchSlateLineup(byRemoteID id: String, context: NSManagedObjectContext? = nil) throws -> SlateLineup? {
        return try fetch(Requests.fetchSlateLineup(byID: id), context: context).first
    }

    func fetchSlates() throws -> [Slate] {
        return try fetch(Requests.fetchSlates())
    }

    func fetchSlate(byRemoteID id: String, context: NSManagedObjectContext? = nil) throws -> Slate? {
        let request = Requests.fetchSlates()
        request.predicate = NSPredicate(format: "remoteID = %@", id)
        request.fetchLimit = 1
        return try fetch(request, context: context).first
    }

    func makeSlateLineupController() -> NSFetchedResultsController<SlateLineup> {
        let request = Requests.fetchSlateLineups()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "requestID", ascending: true)]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func makeSlateController(byID id: String) -> NSFetchedResultsController<Slate> {
        let request = Requests.fetchSlate(byID: id)
        request.sortDescriptors = [NSSortDescriptor(key: "remoteID", ascending: true)]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func batchDeleteOrphanedSlates() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Slate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slateLineup = NULL")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try backgroundContext.performAndWait {
            try backgroundContext.execute(deleteRequest)
        }
    }
}

// MARK: SyndicatedArticle
extension Space {
    func fetchSyndicatedArticle(byItemId id: String, context: NSManagedObjectContext? = nil) throws -> SyndicatedArticle? {
        return try fetch(Requests.fetchSyndicatedArticle(byItemId: id), context: context).first
    }
}

// MARK: Tag
extension Space {
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
        let fetchedTag = (try? fetch(fetchRequest).first) ?? Tag(context: backgroundContext)
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

    func filterTags(with input: String, excluding tags: [String]) throws -> [Tag] {
        return try fetch(Requests.filterTags(with: input, excluding: tags))
    }

    func deleteTag(byID id: String) throws {
        let fetchRequest = Requests.fetchTag(byID: id)
        fetchRequest.fetchLimit = 1
        let tag = try fetch(fetchRequest)
        delete(tag)
    }
}
