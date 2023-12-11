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

    /// Deletes an entity from the specified context.  If context is nil, the default `backgroundContext` is used
    /// - Parameters:
    ///   - object: entity to be removed
    ///   - context: the specified context, or nil.
    func delete(_ object: NSManagedObject, in context: NSManagedObjectContext? = nil) {
        let context = context ?? backgroundContext
        context.performAndWait {
            let object = context.object(with: object.objectID)
            context.delete(object)
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

    /// Saves the specified  context. If context is nil, saves `backgroundContext`
    /// - Parameter context: the specified context, or nil.
    func save(context: NSManagedObjectContext? = nil) throws {
        let context = context ?? backgroundContext
        try context.performAndWait {
            guard context.hasChanges else {
                return
            }
            try context.save()
        }
    }

    /// Calls `performAndWait` on the specified context, passing the specified closure. If context is nil, `backgroundContext` is used
    /// - Parameters:
    ///   - context: the specified context or nil
    ///   - block: the specified closure
    func performAndWait<T>(context: NSManagedObjectContext? = nil, _ block: () throws -> T) rethrows -> T {
        let context = context ?? backgroundContext
        return try context.performAndWait(block)
    }

    /// Calls `attemptMigration` on the specified context, passing the specified closure. If context is nil, `backgroundContext` is used
    /// - Parameters:
    ///   - schedule: schedule type, defaunts to `.immediate`
    ///   - block: the specified closure
    ///   - context: the specified context, or nil
    func perform<T>(schedule: NSManagedObjectContext.ScheduledTaskType = .immediate,
                    context: NSManagedObjectContext? = nil,
                    _ block: @escaping () throws -> T) async rethrows -> T {
        let context = context ?? backgroundContext
        return try await context.perform(schedule: schedule, block)
    }

    func clear() throws {
        try backgroundContext.performAndWait {
            guard let objectModel = backgroundContext.persistentStoreCoordinator?.managedObjectModel else {
                return
            }

            for entity in objectModel.entities {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                let result = try backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [backgroundContext])
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

    /// Creates a child context to `backgroundContext`
    /// - Returns: the child context.
    func makeChildBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = backgroundContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
        return context
    }
}

// MARK: Collection
extension Space {
    func fetchCollection(by slug: String, context: NSManagedObjectContext? = nil) throws -> Collection? {
        return try fetch(Requests.fetchCollection(by: slug), context: context).first
    }

    func fetchCollectionAuthor(by name: String, context: NSManagedObjectContext? = nil) throws -> CollectionAuthor? {
        return try fetch(Requests.fetchCollectionAuthor(by: name), context: context).first
    }

    func fetchCollectionAuthors(by slug: String, context: NSManagedObjectContext? = nil) throws -> [CollectionAuthor] {
        return try fetch(Requests.fetchCollectionAuthors(by: slug))
    }

    func fetchCollectionStory(by url: String, context: NSManagedObjectContext? = nil) throws -> CollectionStory? {
        return try fetch(Requests.fetchCollectionStory(by: url), context: context).first
    }

    func updateCollection(from remote: Collection.RemoteCollection) throws {
        let context = makeChildBackgroundContext()

        context.performAndWait { [weak self] in
            guard let self else { return }

            let collection = (try? fetchCollection(by: remote.slug, context: context)) ??
            Collection(context: context, slug: remote.slug, title: remote.title, authors: [], stories: [])

            collection.update(from: remote, in: self, context: context)
        }

        // save the child context
        try context.performAndWait {
            guard context.hasChanges else {
                return
            }
            try context.save()
            // then save the parent context
            try save()
        }
    }

    func makeCollectionStoriesController(slug: String) -> RichFetchedResultsController<CollectionStory> {
        RichFetchedResultsController(
            fetchRequest: Requests.fetchCollectionStories(by: slug),
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
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

    func fetchItem(byURL url: String, context: NSManagedObjectContext? = nil) throws -> Item? {
        return try fetch(Requests.fetchItem(byURL: url), context: context).first
    }

    func deleteUnsavedItems() throws {
        try delete(fetchUnsavedItems())
    }

    func fetchUnsavedItems() throws -> [Item] {
        return try fetch(Requests.fetchUnsavedItems())
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
    func fetchSavedItem(byURL url: String, context: NSManagedObjectContext? = nil) throws -> SavedItem? {
        return try fetch(Requests.fetchSavedItem(byURL: url), context: context).first
    }

    func fetchSavedItem(byURL url: String) throws -> SavedItem? {
        return try fetch(Requests.fetchSavedItem(byURL: url)).first
    }

    func fetchSavedItems(bySearchTerm searchTerm: String, userPremium isPremium: Bool) throws -> [SavedItem]? {
        return try fetch(Requests.fetchSavedItems(bySearchTerm: searchTerm, userPremium: isPremium))
    }

    func fetchSavedItems(limit: Int? = nil) throws -> [SavedItem] {
        return try fetch(Requests.fetchSavedItems(limit: limit))
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

    func makeSharedWithYouHighlightsController(limit: Int) -> RichFetchedResultsController<SharedWithYouHighlight> {
        RichFetchedResultsController(
            fetchRequest: Requests.fetchSharedWithYouHighlights(limit: limit),
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
    func fetchSlateLineups(context: NSManagedObjectContext? = nil) throws -> [SlateLineup] {
        return try fetch(Requests.fetchSlateLineups(), context: context)
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

    /// Updates unified home lineup from the specified remote object
    /// - Parameter remote: the specified remote object
    func updateHomeLineup(from remote: SlateLineup.RemoteHomeLineup) throws {
        let context = makeChildBackgroundContext()

        try context.performAndWait { [weak self] in
            guard let self else { return }
            let lineups = try self.fetchSlateLineups(context: context)

            lineups.forEach {
                context.delete($0)
            }

            let lineup = SlateLineup(context: context, remoteID: remote.id, expermimentID: "", requestID: "")

            lineup.update(from: remote, in: self, context: context)
        }

        // cleanup and save operations
        try context.performAndWait {
            guard context.hasChanges else {
                return
            }
            // cleanup orphaned entities
            try purgeOrphans(context: context)
            // then save the child context
            try context.save()
            // then save the parent context
            try save()
        }
    }

    private func purgeOrphans(context: NSManagedObjectContext) throws {
        try deleteOrphanedSlates(context: context)
        try deleteOrphanedRecommendations(context: context)
        try deleteOrphanedItems(context: context)
        try deleteOrphanedCollections(context: context)
        try deleteOrphanedStories(context: context)
        try deleteOrphanedSharedWithYouHighlights(context: context)
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

    func fetchOrCreateTag(byName name: String, context: NSManagedObjectContext? = nil) -> Tag {
        let context = context ?? backgroundContext
        let fetchRequest = Requests.fetchTag(byName: name)
        fetchRequest.fetchLimit = 1
        if let fetchedTag = (try? fetch(fetchRequest, context: context).first) {
            return fetchedTag
        }
        let createTag = Tag(context: context)
        createTag.name = name
        return createTag
    }

    func fetchTag(by name: String, context: NSManagedObjectContext? = nil) throws -> Tag? {
        let context = context ?? backgroundContext
        let fetchRequest = Requests.fetchTag(byName: name)
        fetchRequest.fetchLimit = 1
        return try fetch(fetchRequest, context: context).first
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

// MARK: FeatureFlags
extension Space {
    /// Gets a feature flag by name, you should interact with this at an App level via FeatureFlagsService
    /// - Parameter name: Name of the flag in the database
    /// - Parameter context: Context to operate in
    /// - Returns: A feature flag if it exists
    func fetchFeatureFlag(by name: String, in context: NSManagedObjectContext?) throws -> FeatureFlag? {
        let request = Requests.fetchFeatureFlags()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        return try fetch(request, context: context).first
    }

    /// Gets all feature flags in CoreData
    /// - Parameter context: Context to operate in
    /// - Returns: The set of feature flags
    func fetchFeatureFlags(in context: NSManagedObjectContext?) throws -> [FeatureFlag] {
        return try fetch(Requests.fetchFeatureFlags(), context: context)
    }

    /// Returns an NSFetchedResultsController that fetches FeatureFlag objects.
    func makeFeatureFlagsController() -> NSFetchedResultsController<FeatureFlag> {
        let request = Requests.fetchFeatureFlags()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: backgroundContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return resultsController
    }
}

// MARK: cleanup
private extension Space {
    /// Removes all the entities matching a given fetch request
    /// - Parameters:
    ///   - request: the given fetch request
    ///   - context: the context where to perform the delete operations
    func deleteEntities<T: NSManagedObject>(request: NSFetchRequest<T>, context: NSManagedObjectContext) throws {
        try context.performAndWait {
            let orphans = try context.fetch(request)
            orphans.forEach {
                context.delete($0)
            }
        }
    }

    func deleteOrphanedSlates(context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<Slate> = Slate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slateLineup = NULL")
        try deleteEntities(request: fetchRequest, context: context)
    }

    func deleteOrphanedRecommendations(context: NSManagedObjectContext) throws {
        let fetchRequest = Recommendation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "slate = NULL")
        try deleteEntities(request: fetchRequest, context: context)
    }

    func deleteOrphanedItems(context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recommendation = NULL && savedItem = NULL")
        try deleteEntities(request: fetchRequest, context: context)
    }

    func deleteOrphanedCollections(context: NSManagedObjectContext) throws {
        let fetchRequest = Collection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "item = NULL")
        try deleteEntities(request: fetchRequest, context: context)
    }

    func deleteOrphanedStories(context: NSManagedObjectContext) throws {
        let fetchRequest = CollectionStory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "collection = NULL")
        try deleteEntities(request: fetchRequest, context: context)
    }

    func deleteOrphanedSharedWithYouHighlights(context: NSManagedObjectContext) throws {
        let fetchRequest = SharedWithYouHighlight.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "item = NULL")
        try deleteEntities(request: fetchRequest, context: context)
    }
}

extension Space {
    func fetchSharedWithYouHighlight(with url: URL, in context: NSManagedObjectContext?) throws -> SharedWithYouHighlight? {
        let request = Requests.fetchSharedWithYouHighlight()
        request.predicate = NSPredicate(format: "url = %@", url as CVarArg)
        request.fetchLimit = 1
        return try fetch(request, context: context).first
    }
}
