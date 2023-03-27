// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine
import Network
import PocketGraph
import SharedPocketKit

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
    private let networkMonitor: NetworkPathMonitor
    private let retrySignal: PassthroughSubject<Void, Never>
    private let sessionProvider: SessionProvider
    private let backgroundTaskManager: BackgroundTaskManager
    private let osNotificationCenter: OSNotificationCenter
    private let notificationObserver = UUID()
    private let userService: UserService

    private let operations: SyncOperationFactory
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public convenience init(
        space: Space,
        user: User,
        sessionProvider: SessionProvider,
        consumerKey: String,
        defaults: UserDefaults,
        backgroundTaskManager: BackgroundTaskManager
    ) {
        let apollo = ApolloClient.createDefault(
            sessionProvider: sessionProvider,
            consumerKey: consumerKey
        )

        self.init(
            space: space,
            user: user,
            apollo: apollo,
            operations: OperationFactory(),
            lastRefresh: UserDefaultsLastRefresh(defaults: defaults),
            slateService: APISlateService(apollo: apollo, space: space),
            networkMonitor: NWPathMonitor(),
            sessionProvider: sessionProvider,
            backgroundTaskManager: backgroundTaskManager,
            osNotificationCenter: OSNotificationCenter(
                notifications: CFNotificationCenterGetDarwinNotifyCenter()
            ),
            userService: APIUserService(apollo: apollo, space: space, user: user)
        )
    }

    init(
        space: Space,
        user: User,
        apollo: ApolloClientProtocol,
        operations: SyncOperationFactory,
        lastRefresh: LastRefresh,
        slateService: SlateService,
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

    public func makeHomeController() -> NSFetchedResultsController<Recommendation> {
        space.makeRecomendationsSlateLineupController(by: SyncConstants.Home.slateLineupIdentifier)
    }

    public func backgroundObject<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        space.backgroundObject(with: id)
    }

    public func viewObject<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        space.viewObject(with: id)
    }

    public func viewRefresh(_ object: NSManagedObject, mergeChanges flag: Bool) {
        space.viewContext.refresh(object, mergeChanges: flag)
    }

    public func backgroundRefresh(_ object: NSManagedObject, mergeChanges: Bool) {
        space.backgroundRefresh(object, mergeChanges: mergeChanges)
    }

    public func retryImmediately() {
        retrySignal.send()
    }

    private func observeNetworkStatus() {
        networkMonitor.start(queue: .main)
        networkMonitor.updateHandler = { [weak self] path in
            switch path.status {
            case .unsatisfied, .requiresConnection:
                self?.syncQ.isSuspended = true
            case .satisfied:
                self?.syncQ.isSuspended = false
                self?.retrySignal.send()
            @unknown default:
                self?.syncQ.isSuspended = false
            }
        }
    }

    // Exposed to tests to facilitate waiting for all operations to finish
    // Should not be used outside of a testing context
    func drain(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.syncQ.waitUntilAllOperationsAreFinished()
            completion()
        }
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
        if lastRefresh.lastRefreshSaves == nil {
            initialSavesDownloadState.send(.started)
        }

        let operation = operations.fetchSaves(
            user: user,
            apollo: apollo,
            space: space,
            events: _events,
            initialDownloadState: initialSavesDownloadState,
            lastRefresh: lastRefresh
        )

        enqueue(operation: operation, task: .fetchSaves, completion: completion)
    }

    public func refreshArchive(completion: (() -> Void)? = nil) {
        if lastRefresh.lastRefreshArchive == nil {
            initialArchiveDownloadState.send(.started)
        }

        let operation = operations.fetchArchive(
            apollo: apollo,
            space: space,
            events: _events,
            initialDownloadState: initialArchiveDownloadState,
            lastRefresh: lastRefresh
        )

        enqueue(operation: operation, task: .fetchSaves, completion: completion)
    }

    public func favorite(item: SavedItem) {
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? SavedItem,
                  let remoteID = item.remoteID else {
                return
            }

            item.isFavorite = true
            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: FavoriteItemMutation(itemID: remoteID)
            )

            enqueue(operation: operation, task: .favorite(remoteID: remoteID))
        }
    }

    public func unfavorite(item: SavedItem) {
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? SavedItem,
                  let remoteID = item.remoteID else {
                return
            }

            item.isFavorite = false
            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: UnfavoriteItemMutation(itemID: remoteID)
            )
            enqueue(operation: operation, task: .unfavorite(remoteID: remoteID))
        }
    }

    public func delete(item savedItem: SavedItem) {
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem,
                  let remoteID = savedItem.remoteID else {
                return
            }

            let item = savedItem.item

            space.delete(savedItem)

            if let item = item, item.recommendation == nil {
                space.delete(item)
            }

            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: DeleteItemMutation(itemID: remoteID)
            )

            enqueue(operation: operation, task: .delete(remoteID: remoteID))
        }
    }

    public func archive(item: SavedItem) {
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? SavedItem,
                  let remoteID = item.remoteID else {
                return
            }

            item.isArchived = true
            item.archivedAt = Date()
            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: ArchiveItemMutation(itemID: remoteID)
            )

            enqueue(operation: operation, task: .archive(remoteID: remoteID))
        }
    }

    public func unarchive(item: SavedItem) {
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? SavedItem else {
                return
            }
            item.isArchived = false
            item.createdAt = Date()
            try? space.save()

            let operation = operations.saveItemOperation(
                managedItemID: item.objectID,
                url: item.url,
                events: _events,
                apollo: apollo,
                space: space
            )

            enqueue(operation: operation, task: .save(localID: item.objectID.uriRepresentation(), url: item.url))
        }
    }

    public func save(item: SavedItem) {
        let operation = operations.saveItemOperation(
            managedItemID: item.objectID,
            url: item.url,
            events: _events,
            apollo: apollo,
            space: space
        )
        enqueue(operation: operation, task: .save(localID: item.objectID.uriRepresentation(), url: item.url))
    }

    public func addTags(item: SavedItem, tags: [String]) {
        space.performAndWait {
            guard let item = space.backgroundObject(with: item.objectID) as? SavedItem,
                  let remoteID = item.remoteID else {
                return
            }

            item.tags = NSOrderedSet(array: tags.compactMap { $0 }.map({ tag in
                space.fetchOrCreateTag(byName: tag)
            }))

            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: getMutation(for: tags, and: remoteID)
            )

            enqueue(operation: operation, task: .addTags(remoteID: remoteID, tags: tags))
        }
    }

    public func deleteTag(tag: Tag) {
        space.performAndWait {
            guard let tag = space.backgroundObject(with: tag.objectID) as? Tag,
                  let remoteID = tag.remoteID else { return }

            try? space.deleteTag(byID: remoteID)
            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: DeleteTagMutation(id: remoteID)
            )

            enqueue(operation: operation, task: .deleteTag(remoteID: remoteID))
        }
    }

    public func renameTag(from oldTag: Tag, to name: String) {
        space.performAndWait {
            guard let oldTag = space.backgroundObject(with: oldTag.objectID) as? Tag,
                  let remoteID = oldTag.remoteID else { return }

            let fetchedTag = try? space.fetchTag(byID: remoteID)
            fetchedTag?.name = name
            try? space.save()

            let operation = operations.savedItemMutationOperation(
                apollo: apollo,
                events: _events,
                mutation: TagUpdateMutation(input: TagUpdateInput(id: remoteID, name: name))
            )

            enqueue(operation: operation, task: .renameTag(remoteID: remoteID, name: name))
        }
    }

    public func retrieveTags(excluding tags: [String]) -> [Tag]? {
        try? space.retrieveTags(excluding: tags)
    }

    public func fetchAllTags() -> [Tag]? {
        try? space.fetchAllTags()
    }

    public func fetchTags(isArchived: Bool = false) -> [Tag]? {
        try? space.fetchTags(isArchived: isArchived)
    }

    public func filterTags(with input: String, excluding tags: [String]) -> [Tag]? {
        try? space.filterTags(with: input, excluding: tags)
    }

    public func fetchDetails(for savedItem: SavedItem) async throws {
        guard let remoteID = savedItem.remoteID else {
            return
        }

        guard let remoteSavedItem = try await apollo
            .fetch(query: SavedItemByIDQuery(id: remoteID))
            .data?.user?.savedItemById else {
            return
        }

        try space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
                Log.capture(message: "Could not get SavedItem from backgroundContext while fetching details")
                return
            }
            savedItem.update(from: remoteSavedItem.fragments.savedItemParts, with: space)
            try space.save()
        }
    }

    private func getMutation(for tags: [String], and remoteID: String) -> AnyMutation {
        let mutation: AnyMutation
        if tags.isEmpty {
            mutation = AnyMutation(UpdateSavedItemRemoveTagsMutation(savedItemId: remoteID))
        } else {
            mutation = AnyMutation(ReplaceSavedItemTagsMutation(input: [SavedItemTagsInput(savedItemId: remoteID, tags: tags)]))
        }
        return mutation
    }

    public func fetchItem(_ url: URL) -> Item? {
        return try? space.fetchItem(byURL: url)
    }
}

// MARK: - User Info
extension PocketSource {
    public func fetchUserData() async throws {
        try await userService.fetchUser()
    }
}

// MARK: - Slates/Recommendations
extension PocketSource {
    public func fetchSlateLineup(_ identifier: String) async throws {
        try await slateService.fetchSlateLineup(identifier)
    }

    public func fetchSlate(_ slateID: String) async throws {
        try await slateService.fetchSlate(slateID)
    }

    public func fetchDetails(for recommendation: Recommendation) async throws {
        Log.breadcrumb(category: "detail-loading", level: .debug, message: "Loading details for Recomendation: \(String(describing: recommendation.remoteID))")
        guard let item = recommendation.item else {
            Log.capture(message: "Could not fetch details for recommendation due to no item")
            return
        }

        guard let remoteItem = try await apollo
            .fetch(query: ItemByIDQuery(id: item.remoteID))
            .data?.itemByItemId?.fragments.itemParts else {
            return
        }

        try space.performAndWait {
            guard let backgroundItem = space.backgroundObject(with: item.objectID) as? Item else {
                Log.capture(message: "Could not fetch a background item when fetching details for Recommendations")
                return
            }
            backgroundItem.update(remote: remoteItem, with: space)
            try space.save()
        }
    }
}

// MARK: - Enqueueing and Restoring offline operations
extension PocketSource {
    private func enqueue(operation: SyncOperation, task: SyncTask, completion: (() -> Void)? = nil) {
        let persistentTask: PersistentSyncTask = PersistentSyncTask(context: space.backgroundContext)
        persistentTask.createdAt = Date()
        persistentTask.syncTaskContainer = SyncTaskContainer(task: task)
        try? space.save()

        enqueue(operation: operation, persistentTask: persistentTask, completion: completion)
    }

    private func enqueue(operation: SyncOperation, persistentTask: PersistentSyncTask, completion: (() -> Void)? = nil) {
        let _operation = RetriableOperation(
            retrySignal: retrySignal.eraseToAnyPublisher(),
            backgroundTaskManager: backgroundTaskManager,
            operation: operation
        )

        _operation.completionBlock = completion
        syncQ.addOperation(_operation)
        syncQ.addBarrierBlock { [weak self] in
            self?.space.performAndWait { [weak self] in
                self?.space.delete(persistentTask)
                try? self?.space.save()
            }
        }

        if networkMonitor.currentNetworkPath.status == .satisfied {
            retrySignal.send()
        }
    }

    public func restore() {
        guard let persistentTasks = try? space.fetchPersistentSyncTasks() else { return }

        for persistentTask in persistentTasks {
            switch persistentTask.syncTaskContainer?.task {
            case .none:
                break
            case .favorite(let remoteID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: FavoriteItemMutation(itemID: remoteID)
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .fetchSaves:
                let operation = operations.fetchSaves(
                    user: user,
                    apollo: apollo,
                    space: space,
                    events: _events,
                    initialDownloadState: initialSavesDownloadState,
                    lastRefresh: lastRefresh
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .fetchArchive:
                let operation = operations.fetchArchive(
                    apollo: apollo,
                    space: space,
                    events: _events,
                    initialDownloadState: initialArchiveDownloadState,
                    lastRefresh: lastRefresh
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .archive(let remoteID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: ArchiveItemMutation(itemID: remoteID)
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .delete(let remoteID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: DeleteItemMutation(itemID: remoteID)
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .unfavorite(let remoteID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: UnfavoriteItemMutation(itemID: remoteID)
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case let .save(localID, itemURL):
                guard let managedID = space.managedObjectID(forURL: localID) else { return }

                let operation = operations.saveItemOperation(
                    managedItemID: managedID,
                    url: itemURL,
                    events: _events,
                    apollo: apollo,
                    space: space
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .addTags(let remoteID, let tags):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: getMutation(for: tags, and: remoteID)
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .deleteTag(let tagID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: DeleteTagMutation(id: tagID)
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            case .renameTag(let remoteID, let name):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: TagUpdateMutation(input: TagUpdateInput(id: remoteID, name: name))
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            }
        }
    }

    public func resolveUnresolvedSavedItems() {
        guard let unresolved = try? space.fetchUnresolvedSavedItems() else {
            return
        }

        unresolved.compactMap(\.savedItem).forEach(save(item:))
        space.delete(unresolved)
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
        resolveUnresolvedSavedItems()
    }
}

// MARK: - Recommendations
extension PocketSource {
    public func save(recommendation: Recommendation) {
        space.performAndWait {
            guard let recommendation = space.backgroundObject(with: recommendation.objectID) as? Recommendation,
                  let item = recommendation.item, item.bestURL != nil else {
                return
            }

            if let savedItem = recommendation.item?.savedItem {
                unarchive(item: savedItem)
            } else {
                let savedItem: SavedItem = SavedItem(context: space.backgroundContext, url: item.givenURL)
                savedItem.update(from: recommendation)
                try? space.save()

                save(item: savedItem)
            }
        }
    }

    public func archive(recommendation: Recommendation) {
        space.performAndWait {
            guard let recommendation = space.backgroundObject(with: recommendation.objectID) as? Recommendation,
                  let savedItem = recommendation.item?.savedItem, savedItem.isArchived == false else {
                return
            }

            archive(item: savedItem)
        }
    }

    public func remove(recommendation: Recommendation) {
        space.delete(recommendation)
        try? space.save()
    }
}

// MARK: - Image
extension PocketSource {
    public func delete(images: [Image]) {
        space.delete(images)
        try? space.save()
    }
}

// MARK: - URL
extension PocketSource {
    public func save(url: URL) {
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

// MARK: - Search term
extension PocketSource {
    public func searchSaves(search: String) -> [SavedItem]? {
        try? space.fetchSavedItems(bySearchTerm: search, userPremium: user.status == .premium)
    }

    public func fetchOrCreateSavedItem(with remoteID: String, and remoteParts: SavedItem.RemoteSavedItem?) -> SavedItem? {
        let savedItem = (try? space.fetchSavedItem(byRemoteID: remoteID))

        if let remoteParts {
            savedItem?.update(from: remoteParts, with: space)
        }

        guard savedItem == nil, let remoteParts, let url = URL(string: remoteParts.url) else {
            Log.breadcrumb(category: "sync", level: .debug, message: "SavedItem found and don't need to create one")
            return savedItem
        }

        let remoteSavedItem = SavedItem(context: space.backgroundContext, url: url, remoteID: remoteID)
        remoteSavedItem.update(from: remoteParts, with: space)
        try? space.save()

        return remoteSavedItem
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
