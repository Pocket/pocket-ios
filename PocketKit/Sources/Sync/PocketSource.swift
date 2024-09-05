// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine
import Network
import PocketGraph
import SharedPocketKit
import SharedWithYou

public typealias SyncEvents = PassthroughSubject<SyncEvent, Never>

/// Handles the network and database operations of the Pocket App
/// All core data requests should occur through this class.
public class PocketSource: Source {
    private let _events: SyncEvents = PassthroughSubject()
    public var events: AnyPublisher<SyncEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    public var initialSavesDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    public var initialArchiveDownloadState: CurrentValueSubject<InitialDownloadState, Never>

    private let space: Space
    private let user: User
    private let apollo: ApolloClientProtocol
    private let lastRefresh: LastRefresh
    private let slateService: SlateService
    private let collectionService: CollectionService
    private let featureFlagService: FeatureFlagLoadingService
    private let networkMonitor: NetworkPathMonitor
    private let retrySignal: PassthroughSubject<Void, Never>
    private let sessionProvider: SessionProvider
    private let backgroundTaskManager: BackgroundTaskManager
    private let osNotificationCenter: OSNotificationCenter
    private let notificationObserver = UUID()
    private let userService: UserService

    private let operations: SyncOperationFactory

    /// Instantiate a serial operation queue with background QOS
    /// - Parameter queueName: the name of the queue to be instantiated
    /// - Returns: the queue
    private static func makeBackgroundQueue(_ queueName: String) -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        queue.name = queueName
        return queue
    }

    private let saveQueue: OperationQueue = {
        makeBackgroundQueue("com.mozilla.pocket.save")
    }()

    private let fetchSavesQueue: OperationQueue = {
        makeBackgroundQueue("com.mozilla.pocket.fetch.saves")
    }()

    private let fetchArchiveQueue: OperationQueue = {
        makeBackgroundQueue("com.mozilla.pocket.fetch.archive")
    }()

    private let fetchTagsQueue: OperationQueue = {
        makeBackgroundQueue("com.mozilla.pocket.fetch.tags")
    }()

    private let fetchSharedWithYouQueue: OperationQueue = {
        makeBackgroundQueue("com.mozilla.pocket.fetch.sharedWithYou")
    }()

    private var allQueues: [OperationQueue] {
        [
            saveQueue,
            fetchSavesQueue,
            fetchArchiveQueue,
            fetchTagsQueue,
            fetchSharedWithYouQueue
        ]
    }

    public convenience init(
        space: Space,
        user: User,
        appSession: AppSession,
        consumerKey: String,
        defaults: UserDefaults,
        backgroundTaskManager: BackgroundTaskManager
    ) {
        let apollo = ApolloClient.createDefault(
            sessionProvider: appSession as! SessionProvider,
            consumerKey: consumerKey
        )

        self.init(
            space: space,
            user: user,
            apollo: apollo,
            operations: OperationFactory(),
            lastRefresh: UserDefaultsLastRefresh(defaults: defaults),
            slateService: APISlateService(apollo: apollo, space: space),
            collectionService: APICollectionService(apollo: apollo, space: space),
            featureFlagService: APIFeatureFlagService(apollo: apollo, space: space, appSession: appSession),
            networkMonitor: NWPathMonitor(),
            sessionProvider: appSession as! SessionProvider,
            backgroundTaskManager: backgroundTaskManager,
            osNotificationCenter: OSNotificationCenter(
                notifications: CFNotificationCenterGetDarwinNotifyCenter()
            ),
            userService: APIUserService(apollo: apollo, user: user)
        )
    }

    init(
        space: Space,
        user: User,
        apollo: ApolloClientProtocol,
        operations: SyncOperationFactory,
        lastRefresh: LastRefresh,
        slateService: SlateService,
        collectionService: CollectionService,
        featureFlagService: FeatureFlagLoadingService,
        networkMonitor: NetworkPathMonitor,
        sessionProvider: SessionProvider,
        backgroundTaskManager: BackgroundTaskManager,
        osNotificationCenter: OSNotificationCenter,
        userService: UserService
    ) {
        self.space = space
        self.user = user
        self.apollo = apollo
        self.operations = operations
        self.lastRefresh = lastRefresh
        self.slateService = slateService
        self.collectionService = collectionService
        self.featureFlagService = featureFlagService
        self.networkMonitor = networkMonitor
        self.retrySignal = .init()
        self.sessionProvider = sessionProvider
        self.backgroundTaskManager = backgroundTaskManager
        self.osNotificationCenter = osNotificationCenter
        self.initialSavesDownloadState = .init(.unknown)
        self.initialArchiveDownloadState = .init(.unknown)
        self.userService = userService

        if lastRefresh.lastRefreshSaves != nil {
            initialSavesDownloadState.send(.completed)
        }

        if lastRefresh.lastRefreshArchive != nil {
            initialArchiveDownloadState.send(.completed)
        }

        osNotificationCenter.add(observer: notificationObserver, name: .savedItemCreated) { [weak self] in
            self?.handleSavedItemCreatedNotification()
        }

        osNotificationCenter.add(observer: notificationObserver, name: .savedItemUpdated) { [weak self] in
            self?.handleSavedItemsUpdatedNotification()
        }

        osNotificationCenter.add(observer: notificationObserver, name: .unresolvedSavedItemCreated) { [weak self] in
            self?.handleUnresolvedSavedItemCreatedNotification()
        }

        observeNetworkStatus()
    }

    deinit {
        osNotificationCenter.remove(observer: notificationObserver, name: .savedItemCreated)
        osNotificationCenter.remove(observer: notificationObserver, name: .savedItemUpdated)
        osNotificationCenter.remove(observer: notificationObserver, name: .unresolvedSavedItemCreated)
    }

    public var viewContext: NSManagedObjectContext {
        space.viewContext
    }

    public func clear() {
        lastRefresh.reset()
        try? space.clear()
    }

    public func makeSavesController() -> SavedItemsController {
        FetchedSavedItemsController(
            resultsController: space.makeItemsController()
        )
    }

    public func makeArchiveController() -> SavedItemsController {
        FetchedSavedItemsController(
            resultsController: space.makeArchivedItemsController()
        )
    }

    public func makeSearchService() -> SearchService {
        PocketSearchService(apollo: apollo)
    }

    public func makeImagesController() -> ImagesController {
        FetchedImagesController(resultsController: space.makeImagesController())
    }

    public func makeRecentSavesController() -> NSFetchedResultsController<SavedItem> {
        space.makeRecentSavesController(limit: SyncConstants.Home.recentSaves)
    }

    public func makeHomeController() -> RichFetchedResultsController<Recommendation> {
        space.makeRecomendationsSlateLineupController()
    }

    public func makeFeatureFlagsController() -> NSFetchedResultsController<FeatureFlag> {
        space.makeFeatureFlagsController()
    }

    public func makeCollectionStoriesController(slug: String) -> RichFetchedResultsController<CDCollectionStory> {
        space.makeCollectionStoriesController(slug: slug)
    }

    public func viewObject<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        space.viewObject(with: id)
    }

    public func viewRefresh(_ object: NSManagedObject, mergeChanges flag: Bool) {
        space.viewContext.refresh(object, mergeChanges: flag)
    }

    public func retryImmediately() {
        retrySignal.send()
    }

    private func shouldSuspendQueues(_ isSuspended: Bool) {
        allQueues.forEach {
            $0.isSuspended = isSuspended
        }
    }

    private func suspendQueues() {
        shouldSuspendQueues(true)
    }

    private func resumeQueues() {
        shouldSuspendQueues(false)
    }

    private func observeNetworkStatus() {
        networkMonitor.start(queue: .global(qos: .background))
        networkMonitor.updateHandler = { [weak self] path in
            switch path.status {
            case .unsatisfied, .requiresConnection:
                self?.suspendQueues()
            case .satisfied:
                self?.resumeQueues()
                self?.retrySignal.send()
            @unknown default:
                self?.resumeQueues()
            }
        }
    }

    // Exposed to tests to facilitate waiting for all operations to finish
    // Should not be used outside of a testing context
    func drain(_ completion: @escaping () -> Void) {
        allQueues.forEach {
            $0.waitUntilAllOperationsAreFinished()
        }
        completion()
    }

    /// Sends the delete call to Backend, you must still implement the logout and reset functionality.
    public func deleteAccount() async throws {
        let result = try await apollo.perform(mutation: DeleteUserMutation())

        guard let errors = result.errors, let firstError = errors.first else {
            // No error! Yay!
            return
        }

        // Throw the first error because this mutation does not allow parital success.
        throw firstError
    }
}

// MARK: - Saves/Archive items
extension PocketSource {
    public func refreshSaves(completion: (() -> Void)? = nil) {
        let operation = operations.fetchSaves(
            apollo: apollo,
            space: space,
            events: _events,
            initialDownloadState: initialSavesDownloadState,
            lastRefresh: lastRefresh
        )

        enqueue(operation: operation, task: .fetchSaves, queue: fetchSavesQueue, completion: completion)
    }

    public func refreshArchive(completion: (() -> Void)? = nil) {
        let operation = operations.fetchArchive(
            apollo: apollo,
            space: space,
            events: _events,
            initialDownloadState: initialArchiveDownloadState,
            lastRefresh: lastRefresh
        )

        enqueue(operation: operation, task: .fetchSaves, queue: fetchArchiveQueue, completion: completion)
    }

    public func refreshTags(completion: (() -> Void)? = nil) {
        let operation = operations.fetchTags(
            apollo: apollo,
            space: space,
            events: _events,
            lastRefresh: lastRefresh
        )

        enqueue(operation: operation, task: .fetchSaves, queue: fetchTagsQueue, completion: completion)
    }

    public func favorite(item: SavedItem) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Favoriting item with id \(String(describing: item.remoteID))")
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: item.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            savedItem.isFavorite = true
            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            // Fall back to SavedItem.url if a nested item.givenURL does not exist
            // This may occur when an item has been saved offline, but not yet archived
            let givenURL = savedItem.item?.givenURL ?? savedItem.url
            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: FavoriteItemMutation(
                    givenUrl: givenURL,
                    timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                )
            )

            enqueue(operation: operation, task: .favorite(givenURL: givenURL), queue: saveQueue)
        }
    }

    public func unfavorite(item: SavedItem) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Unfavoriting item with id \(String(describing: item.remoteID))")
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: item.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            savedItem.isFavorite = false
            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            // Fall back to SavedItem.url if a nested item.givenURL does not exist
            // This may occur when an item has been saved offline, but not yet archived
            let givenURL = savedItem.item?.givenURL ?? savedItem.url
            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: UnfavoriteItemMutation(
                    givenUrl: givenURL,
                    timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                )
            )
            enqueue(operation: operation, task: .unfavorite(givenURL: givenURL), queue: saveQueue)
        }
    }

    public func delete(item savedItem: SavedItem) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Deleting item with id \(String(describing: savedItem.remoteID))")
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            // Fall back to SavedItem.url if a nested item.givenURL does not exist
            // This may occur when an item has been saved offline, but not yet archived
            let givenURL = savedItem.item?.givenURL ?? savedItem.url
            let item = savedItem.item

            space.delete(savedItem)

            if let item = item, item.recommendation == nil {
                space.delete(item)
            }

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: DeleteItemMutation(
                    givenUrl: givenURL,
                    timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                )
            )

            enqueue(operation: operation, task: .delete(givenURL: givenURL), queue: saveQueue)
        }
    }

    public func archive(item: SavedItem) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Archiving item with id \(String(describing: item.remoteID))")
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: item.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            savedItem.isArchived = true
            savedItem.archivedAt = Date()

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            // Fall back to SavedItem.url if a nested item.givenURL does not exist
            // This may occur when an item has been saved offline, but not yet archived
            let givenURL = savedItem.item?.givenURL ?? savedItem.url
            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: ArchiveItemMutation(
                    givenUrl: givenURL,
                    timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                )
            )

            enqueue(operation: operation, task: .archive(givenURL: givenURL), queue: saveQueue)
        }
    }

    public func unarchive(item: SavedItem) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Unarchiving item with id \(String(describing: item.remoteID))")
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: item.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }
            savedItem.isArchived = false
            savedItem.createdAt = Date()

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            let operation = operations.saveItemOperation(
                managedItemID: savedItem.objectID,
                url: savedItem.url,
                events: _events,
                apollo: apollo,
                space: space
            )

            enqueue(operation: operation, task: .save(localID: savedItem.objectID.uriRepresentation(), url: item.url), queue: saveQueue)
        }
    }

    public func save(item: SavedItem) {
        // Not logging url for privacy
        Log.breadcrumb(category: "sync", level: .debug, message: "Saving item")
        let operation = operations.saveItemOperation(
            managedItemID: item.objectID,
            url: item.url,
            events: _events,
            apollo: apollo,
            space: space
        )
        enqueue(operation: operation, task: .save(localID: item.objectID.uriRepresentation(), url: item.url), queue: saveQueue)
    }

    public func deleteHighlight(highlight: Highlight) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Deleting a single highlight")
        space.performAndWait {
            guard let highlight = space.backgroundObject(with: highlight.objectID) as? Highlight, let remoteID = highlight.remoteID else {
                Log.capture(message: "Could not retreive highlight from background context for mutation")
                return
            }

            do {
                try space.deleteHighlight(by: remoteID)
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: DeleteSavedItemHighlightMutation(highlightId: remoteID)
            )

            enqueue(operation: operation, task: .deleteHighlight(remoteID: remoteID), queue: saveQueue)
        }
    }

    public func addHighlight(itemIID: NSManagedObjectID, patch: String, quote: String) {
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: itemIID) as? SavedItem, let context = savedItem.managedObjectContext, let itemID = savedItem.remoteID else {
                Log.capture(message: "Could not retreive Saved Item to add highlight from background context for mutation")
                return
            }

            let remoteID = UUID().uuidString

            let highlight = Highlight(
                context: context,
                remoteID: remoteID,
                createdAt: Date(),
                updatedAt: Date(),
                patch: patch,
                quote: quote,
                version: 2
            )
            var highlights = (savedItem.highlights?.array ?? [])
            highlights.append(highlight)
            savedItem.highlights = NSOrderedSet(array: highlights)

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            let mutation = CreateSavedItemHighlightsMutation(
                input: [
                    CreateHighlightInput(
                        id: .some(remoteID),
                        quote: quote,
                        patch: patch,
                        version: 2,
                        itemId: itemID
                    )
                ]
            )

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: mutation
            )

            enqueue(operation: operation, task: .createHighlight(quote: quote, patch: patch, version: 2, itemId: remoteID), queue: saveQueue)
        }
    }

    public func addTags(item: SavedItem, tags: [String]) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Adding tags to item with id \(String(describing: item.remoteID))")
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            item.tags = NSOrderedSet(array: tags.compactMap { $0 }.map({ tag in
                space.fetchOrCreateTag(byName: tag)
            }))

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            guard let mutation = addTagsMutation(for: item, tags: tags),
            let task = addTagsSyncTask(for: item, tags: tags) else {
                Log.capture(message: "Could not retreive add tags mutation and sync task for SavedItem")
                return
            }

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: mutation
            )

            enqueue(operation: operation, task: task, queue: saveQueue)
        }
    }

    public func replaceTags(_ savedItem: SavedItem, tags: [String]) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Replacing tags on saved item with id \(String(describing: savedItem.remoteID))")
        space.performAndWait {
            guard let existingSavedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive saved item from background context for mutation")
                return
            }

            existingSavedItem.tags = NSOrderedSet(array: tags.compactMap { $0 }.map({ tag in
                space.fetchOrCreateTag(byName: tag)
            }))

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            guard let mutation = replaceTagsMutation(for: existingSavedItem, tags: tags),
                  let task = replaceSyncTask(for: existingSavedItem, tags: tags) else {
                Log.capture(message: "Could not construct replace tags mutation and sync task for SavedItem")
                return
            }

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: mutation
            )

            enqueue(operation: operation, task: task, queue: saveQueue)
        }
    }

    public func deleteTag(tag: Tag) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Deleting tags")
        space.performAndWait {
            guard let tag = space.backgroundObject(with: tag.objectID) as? Tag,
                  let remoteID = tag.remoteID else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            do {
                try space.deleteTag(byID: remoteID)
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: DeleteTagMutation(id: remoteID)
            )

            enqueue(operation: operation, task: .deleteTag(remoteID: remoteID), queue: saveQueue)
        }
    }

    public func renameTag(from oldTag: Tag, to name: String) {
        Log.breadcrumb(category: "sync", level: .debug, message: "Renaming tag")
        space.performAndWait {
            guard let oldTag = space.backgroundObject(with: oldTag.objectID) as? Tag else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return
            }

            guard (try? space.fetchTag(by: name)) == nil else {
                Log.capture(message: "A tag with the selected name already exists")
                return
            }

            let fetchedTag = try? space.fetchTag(by: oldTag.name)
            fetchedTag?.name = name

            do {
                try space.save()
            } catch {
                Log.capture(error: error)
            }

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: TagUpdateMutation(input: TagUpdateInput(id: oldTag.remoteID ?? "", name: name))
            )

            enqueue(operation: operation, task: .renameTag(remoteID: oldTag.remoteID ?? "", name: name), queue: saveQueue)
        }
    }

    public func retrieveTags(excluding tags: [String]) -> [Tag]? {
        try? space.retrieveTags(excluding: tags)
    }

    public func fetchAllTags() -> [Tag]? {
        try? space.fetchAllTags()
    }

    public func filterTags(with input: String, excluding tags: [String]) -> [Tag]? {
        try? space.filterTags(with: input, excluding: tags)
    }

    public func fetchDetails(for savedItem: SavedItem) async throws -> Bool {
        Log.breadcrumb(category: "sync", level: .debug, message: "Fetching details for item with id \(String(describing: savedItem.remoteID))")

        guard let remoteID = savedItem.remoteID else {
            return false
        }

        guard let remoteSavedItem = try await apollo
            .fetch(query: SavedItemByIDQuery(id: remoteID))
            .data?.user?.savedItemById else {
            return false
        }

        return try space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
                Log.capture(message: "Could not retreive item from background context for mutation")
                return false
            }
            savedItem.update(from: remoteSavedItem.fragments.savedItemParts, with: space)
            try space.save()

            return remoteSavedItem.item.asItem?.marticle?.isEmpty == false
        }
    }

    private func addTagsMutation(for savedItem: SavedItem, tags: [String]) -> AnyMutation? {
        if tags.isEmpty {
            guard let remoteID = savedItem.remoteID else {
                Log.capture(message: "Could not retreive remoteID from SavedItem for mutation")
                return nil
            }

            return AnyMutation(updateSavedItemRemoveTagsMutation(remoteID: remoteID))
        } else {
            guard let givenURL = savedItem.item?.givenURL else {
                Log.capture(message: "Could not retreive givenURL from SavedItem.Item for mutation")
                return nil
            }

            return AnyMutation(savedItemTagMutation(url: givenURL, tags: tags))
        }
    }

    private func replaceTagsMutation(for savedItem: SavedItem, tags: [String]) -> AnyMutation? {
        guard let remoteID = savedItem.remoteID else {
            Log.capture(message: "Could not retreive remoteID from SavedItem for mutation")
            return nil
        }
        guard !tags.isEmpty else {
            return AnyMutation(updateSavedItemRemoveTagsMutation(remoteID: remoteID))
        }

        return AnyMutation(
            ReplaceSavedItemTagsMutation(
                input: [
                    SavedItemTagsInput(
                        savedItemId: remoteID,
                        tags: tags
                    )
                ]
            )
        )
    }

    private func savedItemTagMutation(url: String, tags: [String]) -> SavedItemTagMutation {
        return SavedItemTagMutation(
            input: SavedItemTagInput(
                givenUrl: url,
                tagNames: tags
            ),
            timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
        )
    }

    private func updateSavedItemRemoveTagsMutation(remoteID: String) -> UpdateSavedItemRemoveTagsMutation {
        return UpdateSavedItemRemoveTagsMutation(savedItemId: remoteID)
    }

    private func addTagsSyncTask(for savedItem: SavedItem, tags: [String]) -> SyncTask? {
        if tags.isEmpty {
            guard let remoteID = savedItem.remoteID else {
                Log.capture(message: "Could not retreive remoteID from SavedItem for mutation")
                return nil
            }

            return .clearTags(remoteID: remoteID)
        } else {
            guard let givenURL = savedItem.item?.givenURL else {
                Log.capture(message: "Could not retreive givenURL from SavedItem.Item for mutation")
                return nil
            }

            return .addTags(givenURL: givenURL, tags: tags)
        }
    }

    private func replaceSyncTask(for savedItem: SavedItem, tags: [String]) -> SyncTask? {
        guard let remoteID = savedItem.remoteID else {
            Log.capture(message: "Could not retreive remoteID from SavedItem for mutation")
            return nil
        }
        if tags.isEmpty {
            return .clearTags(remoteID: remoteID)
        } else {
            return .replaceTags(remoteID: remoteID, tags: tags)
        }
    }

    public func fetchItem(_ url: String) -> Item? {
        return try? space.fetchItem(byURL: url)
    }

    public func fetchViewContextItem(_ url: String) -> Item? {
        return try? space.fetchItem(byURL: url, context: viewContext)
    }
}

// MARK: - User Info
extension PocketSource {
    public func fetchUserData() async throws {
        try await userService.fetchUser()
    }
}

// MARK: - Feature Flags

extension PocketSource {
    public func fetchAllFeatureFlags() async throws {
        try await featureFlagService.fetchFeatureFlags()
    }

    public func fetchFeatureFlag(by name: String) -> FeatureFlag? {
        try? space.fetchFeatureFlag(by: name, in: space.backgroundContext)
    }
}

// MARK: - Slates/Recommendations
extension PocketSource {
    public func fetchUnifiedHomeLineup() async throws {
        try await slateService.fetchHomeSlateLineup()
    }

    public func fetchDetails(for item: Item) async throws -> Bool {
        Log.breadcrumb(category: "recommendations", level: .debug, message: "Loading details for Recomendation: \(String(describing: item.remoteID))")

        guard let remoteItem = try await apollo
            .fetch(query: ItemByURLQuery(url: item.givenURL))
            .data?.itemByUrl?.fragments.itemParts else {
            return false
        }

        return try space.performAndWait {
            guard let backgroundItem = space.backgroundObject(with: item.objectID) as? Item else {
                Log.capture(message: "Could not fetch a background item when fetching details for Recommendations")
                return false
            }
            backgroundItem.update(remote: remoteItem, with: space)
            try space.save()

            return remoteItem.marticle?.isEmpty == false
        }
    }

    public func fetchShortUrlViewItem(_ url: String) async throws -> Item? {
        guard let resolvedItemData = try await apollo
            .fetch(query: ResolveItemUrlQuery(url: url)).data else {
            return nil
        }
        // attempt to retrieve the saved item
        if let savedItemUrl = resolvedItemData.itemByUrl?.savedItem?.url,
           let savedItem = fetchViewContextSavedItem(savedItemUrl),
           let item = savedItem.item {
            return item
        } else if let resolvedUrl = resolvedItemData.itemByUrl?.resolvedUrl,
                  let savedItem = fetchViewContextSavedItem(resolvedUrl),
                  let item = savedItem.item {
            return item
        } else if let normalUrl = resolvedItemData.itemByUrl?.normalUrl,
                  let savedItem = fetchViewContextSavedItem(normalUrl),
                  let item = savedItem.item {
            return item
        } else if let itemUrl = resolvedItemData.itemByUrl?.givenUrl {
            // otherwise, just try to fetch the item
            return try await fetchViewItem(from: itemUrl)
        }
        return nil
    }

    public func fetchViewItem(from url: String) async throws -> Item? {
        if let item = fetchViewContextItem(url) {
            defer {
                Task {
                    if let remoteItem = try await apollo
                        .fetch(query: ItemByURLQuery(url: url))
                        .data?.itemByUrl?.fragments.itemParts {
                        try viewContext.performAndWait {
                            item.update(remote: remoteItem, with: space)
                            try space.save(context: viewContext)
                        }
                    }
                }
            }
            return item
        }

        guard let remoteItem = try await apollo
            .fetch(query: ItemByURLQuery(url: url))
            .data?.itemByUrl?.fragments.itemParts else {
            return nil
        }
        let context = space.viewContext
        let updatedItem = try context.performAndWait {
            let item = Item(context: context, givenURL: remoteItem.givenUrl, remoteID: remoteItem.remoteID)
            item.update(remote: remoteItem, with: space)
            try space.save(context: context)
            return item
        }
        return updatedItem
    }
}

// MARK: - Collections
extension PocketSource {
    public func fetchCollection(by slug: String) async throws {
        try await collectionService.fetchCollection(by: slug)
    }

    public func fetchCollectionAuthors(by slug: String) -> [CDCollectionAuthor] {
        (try? space.fetchCollectionAuthors(by: slug)) ?? []
    }
}

// MARK: - Enqueueing and Restoring offline operations
extension PocketSource {
    /// Creates a PersistentSync task and a RetriableOperation from a SyncTask request and enqueues it onto the Operation Queue to be performed
    /// - Parameters:
    ///   - operation: The sync operation with the executable operation code
    ///   - task: The sync task to turn into a persistent sync task
    ///   - queue: The operation queue to run the task on
    ///   - completion: The completion block to execute when the operation is done. If you need to do cleanup work, you should instead do the completion work within the operation itself because they launch BackgroundTasks
    private func enqueue(operation: SyncOperation, task: SyncTask, queue: OperationQueue, completion: (() -> Void)? = nil) {
        let childBGContext = space.makeChildBackgroundContext()
        let persistentTask: PersistentSyncTask = PersistentSyncTask(context: childBGContext)
        persistentTask.createdAt = Date()
        persistentTask.syncTaskContainer = SyncTaskContainer(task: task)

        // save the child context
        try? childBGContext.performAndWait {
            guard childBGContext.hasChanges else {
                return
            }
            try childBGContext.save()
            // then save the parent context
            try space.save()
        }

        enqueue(operation: operation, persistentTask: persistentTask, queue: queue, completion: completion)
    }

    /// Creates a RetriableOperation from a PersistentSyncTask and enqueues it onto the Operation Queue to be performed
    /// - Parameters:
    ///   - operation: The sync operation with the executable operation code
    ///   - persistentTask: The persistent sync task to track the task to disk
    ///   - queue: The operation queue to run the task on
    ///   - completion: The completion block to execute when the operation is done. If you need to do cleanup work, you should instead do the completion work within the operation itself because they launch BackgroundTasks
    private func enqueue(operation: SyncOperation, persistentTask: PersistentSyncTask, queue: OperationQueue, completion: (() -> Void)? = nil) {
        let _operation = RetriableOperation(
            retrySignal: retrySignal.eraseToAnyPublisher(),
            backgroundTaskManager: backgroundTaskManager,
            operation: operation,
            space: space,
            syncTaskId: persistentTask.objectID
        )

        _operation.completionBlock = {
            guard let completion else {
                return
            }
            completion()
        }
        queue.addOperation(_operation)

        if networkMonitor.currentNetworkPath.status == .satisfied {
            retrySignal.send()
        }
    }

    /// Restores all Persistent tasks from CoreData into their respective operation queues.
    public func restore() {
        guard let persistentTasks = try? space.fetchPersistentSyncTasks() else { return }

        for persistentTask in persistentTasks {
            switch persistentTask.syncTaskContainer?.task {
            case .none:
                break
            case .favorite(let givenURL):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: FavoriteItemMutation(
                        givenUrl: givenURL,
                        timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                    )
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .fetchSaves:
                let operation = operations.fetchSaves(
                    apollo: apollo,
                    space: space,
                    events: _events,
                    initialDownloadState: initialSavesDownloadState,
                    lastRefresh: lastRefresh
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.fetchSavesQueue)
            case .fetchArchive:
                let operation = operations.fetchArchive(
                    apollo: apollo,
                    space: space,
                    events: _events,
                    initialDownloadState: initialArchiveDownloadState,
                    lastRefresh: lastRefresh
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.fetchArchiveQueue)
            case .fetchTags:
                let operation = operations.fetchTags(
                    apollo: apollo,
                    space: space,
                    events: _events,
                    lastRefresh: lastRefresh
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.fetchTagsQueue)
            case .archive(let givenURL):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: ArchiveItemMutation(
                        givenUrl: givenURL,
                        timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                    )
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .delete(let givenURL):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: DeleteItemMutation(
                        givenUrl: givenURL,
                        timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                    )
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .unfavorite(let givenURL):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: UnfavoriteItemMutation(
                        givenUrl: givenURL,
                        timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                    )
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case let .save(localID, itemURL):
                guard let managedID = space.managedObjectID(forURL: localID) else { return }

                let operation = operations.saveItemOperation(
                    managedItemID: managedID,
                    url: itemURL,
                    events: _events,
                    apollo: apollo,
                    space: space
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .addTags(let givenURL, let tags):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: savedItemTagMutation(url: givenURL, tags: tags)
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .replaceTags(let remoteID, let tags):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: ReplaceSavedItemTagsMutation(
                        input: [
                            SavedItemTagsInput(
                                savedItemId: remoteID,
                                tags: tags
                            )
                        ]
                    )
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .clearTags(let remoteID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: updateSavedItemRemoveTagsMutation(remoteID: remoteID)
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .deleteTag(let tagID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: DeleteTagMutation(id: tagID)
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .renameTag(let remoteID, let name):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: TagUpdateMutation(input: TagUpdateInput(id: remoteID, name: name))
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .deleteHighlight(let ID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: DeleteSavedItemHighlightMutation(highlightId: ID)
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .some(.createHighlight(quote: let quote, patch: let patch, version: let version, itemId: let itemId)):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: CreateSavedItemHighlightsMutation(
                        input: [
                            CreateHighlightInput(
                                quote: quote,
                                patch: patch,
                                version: version,
                                itemId: itemId
                            )
                        ]
                    )
                )
                enqueue(operation: operation, persistentTask: persistentTask, queue: self.saveQueue)
            case .fetchSharedWithYouItems(let urls):
                let operation = operations.fetchSharedWithYouItems(apollo: apollo, space: space, urls: urls)
                enqueue(operation: operation, persistentTask: persistentTask, queue: fetchSharedWithYouQueue)
            }
        }
    }

    public func resolveUnresolvedSavedItems(completion: (() -> Void)?) {
        guard let unresolved = try? space.fetchUnresolvedSavedItems() else {
            completion?()
            return
        }

        unresolved.compactMap(\.savedItem).forEach(save(item:))
        space.delete(unresolved)
        do {
            try space.save()
        } catch {
            Log.capture(error: error)
        }
        completion?()
    }
}

// MARK: - Interprocess notifications
extension PocketSource {
    func handleSavedItemsUpdatedNotification() {
        space.performAndWait {
            guard let notifications = try? space.fetchSavedItemUpdatedNotifications() else {
                return
            }

            let updatedSavedItems = Set(notifications.compactMap(\.savedItem))
            space.delete(notifications)
            try? space.save()
            _events.send(.savedItemsUpdated(updatedSavedItems))
        }
    }

    func handleSavedItemCreatedNotification() {
        _events.send(.savedItemCreated)
    }

    func handleUnresolvedSavedItemCreatedNotification() {
        resolveUnresolvedSavedItems(completion: nil)
    }
}

// MARK: - Recommendations
extension PocketSource {
    public func save(recommendation: Recommendation) {
        space.performAndWait {
            guard let recommendation = space.backgroundObject(with: recommendation.objectID) as? Recommendation else {
                return
            }

            let givenURL = recommendation.item.givenURL
            if let savedItem = try? space.fetchSavedItem(byURL: givenURL) {
                unarchive(item: savedItem)
            } else {
                let savedItem: SavedItem = SavedItem(context: space.backgroundContext, url: givenURL)
                savedItem.update(from: recommendation)
                try? space.save()

                save(item: savedItem)
            }
        }
    }

    public func save(item: Item) {
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? Item else {
                return
            }
            let givenURL = item.givenURL
            if let savedItem = try? space.fetchSavedItem(byURL: givenURL) {
                unarchive(item: savedItem)
            } else {
                let savedItem: SavedItem = SavedItem(context: space.backgroundContext, url: givenURL)
                savedItem.update(from: item)
                try? space.save()

                save(item: savedItem)
            }
        }
    }

    public func save(collectionStory: CDCollectionStory) {
        space.performAndWait {
            guard let collectionStory = space.backgroundObject(with: collectionStory.objectID) as? CDCollectionStory,
            let givenURL = collectionStory.item?.givenURL else {
                return
            }
            if let savedItem = try? space.fetchSavedItem(byURL: givenURL) {
                unarchive(item: savedItem)
            } else {
                let savedItem: SavedItem = SavedItem(context: space.backgroundContext, url: givenURL)
                savedItem.createdAt = Date()
                savedItem.item = collectionStory.item
                try? space.save()

                save(item: savedItem)
            }
        }
    }

    public func archive(recommendation: Recommendation) {
        space.performAndWait {
            guard let recommendation = space.backgroundObject(with: recommendation.objectID) as? Recommendation,
                  let savedItem = recommendation.item.savedItem, savedItem.isArchived == false else {
                return
            }

            archive(item: savedItem)
        }
    }

    public func archive(collectionStory: CDCollectionStory) {
        space.performAndWait {
            guard let collectionStory = space.backgroundObject(with: collectionStory.objectID) as? CDCollectionStory,
                  let savedItem = collectionStory.item?.savedItem, savedItem.isArchived == false else {
                return
            }
            archive(item: savedItem)
        }
    }

    public func remove(recommendation: Recommendation) {
        space.performAndWait {
            guard let recommendation = space.backgroundObject(with: recommendation.objectID) as? Recommendation else {
                return
            }

            space.delete(recommendation)
            try? space.save()
        }
    }
}

// MARK: - Image
extension PocketSource {
    public func delete(images: [Image]) {
        space.performAndWait {
            let images = images.compactMap { image in
               return space.backgroundObject(with: image.objectID) as? Image
            }
            space.delete(images)
            try? space.save()
        }
    }
}

// MARK: - URL
extension PocketSource {
    public func save(url: String) {
        space.performAndWait {
            if let savedItem = try? space.fetchSavedItem(byURL: url) {
                unarchive(item: savedItem)
            } else {
                let savedItem: SavedItem = SavedItem(context: space.backgroundContext, url: url)
                savedItem.url = url
                savedItem.createdAt = Date()
                try? space.save()

                save(item: savedItem)
            }
        }
    }
}

// MARK: Shared With You
extension PocketSource {
    public func updateSharedWithYouItems(with urls: [String]) {
        let operation = operations.fetchSharedWithYouItems(apollo: apollo, space: space, urls: urls)
        enqueue(operation: operation, task: .fetchSharedWithYouItems(urls: urls), queue: fetchSharedWithYouQueue)
    }

    public func makeSharedWithYouController() -> RichFetchedResultsController<SharedWithYouItem> {
        space.makeSharedWithYouController()
    }

    public func deleteAllSharedWithYouItems() throws {
        try space.deleteSharedWithYouItems()
    }

    public func item(by slug: String) async throws -> Item? {
        let data = try await apollo.fetch(query: ShareSlugQuery(slug: slug))
        guard let givenUrl = data.data?.shareSlug?.asPocketShare?.preview?.item?.givenUrl else {
            // TODO: we might want to use the share not found message
            return nil
        }
        return try await fetchViewItem(from: givenUrl)
    }

    public func readerItem(by slug: String) async throws -> (SavedItem?, Item?) {
        let data = try await apollo.fetch(query: ReaderSlugQuery(readerSlugSlug: slug))

        if let savedItemUrl = data.data?.readerSlug.savedItem?.url, let savedItem = fetchViewContextSavedItem(savedItemUrl) {
            return (savedItem, nil)
        } else if let itemUrl = data.data?.readerSlug.fallbackPage?.asReaderInterstitial?.itemCard?.item?.givenUrl,
                  let item = try await fetchViewItem(from: itemUrl) {
            if let savedItem = item.savedItem {
                return (savedItem, nil)
            } else {
                return (nil, item)
            }
        }
        return (nil, nil)
    }

    public func requestShareUrl(_ itemUrl: String) async throws -> String? {
        guard let shareUrl = try await apollo.perform(
            mutation: CreateShareLinkMutation(
                target: itemUrl
            )
        )
        .data?
        .createShareLink?
            .shareUrl else {
            return nil
        }
        defer {
            try? updateItemShareUrl(itemUrl, shareUrl: shareUrl)
        }
        return shareUrl
    }

    private func updateItemShareUrl(_ itemUrl: String, shareUrl: String) throws {
        guard let item = try space.fetchItem(byURL: itemUrl) else {
            return
        }
        item.shareURL = shareUrl
        try space.save()
    }
}

// MARK: - Search term
extension PocketSource {
    public func searchSaves(search: String) -> [SavedItem]? {
        try? space.fetchSavedItems(bySearchTerm: search, userPremium: user.status == .premium)
    }

    public func fetchOrCreateSavedItem(with url: String, and remoteParts: SavedItem.RemoteSavedItem?) -> SavedItem? {
        let savedItem = (try? space.fetchSavedItem(byURL: url))

        if let remoteParts {
            savedItem?.update(from: remoteParts, with: space)
        }

        guard savedItem == nil, let remoteParts else {
            Log.breadcrumb(category: "sync", level: .debug, message: "SavedItem found and don't need to create one")
            // save the space with the updated item data
            try? space.save()
            return savedItem
        }

        let remoteSavedItem = SavedItem(context: space.backgroundContext, url: url, remoteID: remoteParts.remoteID)
        remoteSavedItem.update(from: remoteParts, with: space)
        try? space.save()

        return remoteSavedItem
    }

    public func fetchViewContextSavedItem(_ url: String) -> SavedItem? {
        try? space.fetchSavedItem(byURL: url, context: viewContext)
    }
}

// MARK: UI Helpers
/// Functions used by the UI
extension PocketSource {
    /// Get the count of unread saves
    /// - Returns: Int of unread saves
    public func unreadSaves() throws -> Int {
        return try space.fetch(Requests.fetchSavedItems()).count
    }
}
// MARK: ObjectID from URI Representation
extension PocketSource {
    public func objectID(from uri: URL) -> NSManagedObjectID? {
        viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri)
    }
}
