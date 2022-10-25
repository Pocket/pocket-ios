// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine
import Network
import PocketGraph

public typealias SyncEvents = PassthroughSubject<SyncEvent, Never>

public class PocketSource: Source {
    private let _events: SyncEvents = PassthroughSubject()
    public var events: AnyPublisher<SyncEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    public var initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>

    private let space: Space
    private let apollo: ApolloClientProtocol
    private let lastRefresh: LastRefresh
    private let slateService: SlateService
    private let networkMonitor: NetworkPathMonitor
    private let retrySignal: PassthroughSubject<Void, Never>
    private let sessionProvider: SessionProvider
    private let backgroundTaskManager: BackgroundTaskManager
    private let osNotificationCenter: OSNotificationCenter
    private let notificationObserver = UUID()

    private let operations: SyncOperationFactory
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public convenience init(
        space: Space,
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
            apollo: apollo,
            operations: OperationFactory(),
            lastRefresh: UserDefaultsLastRefresh(defaults: defaults),
            slateService: APISlateService(apollo: apollo, space: space),
            networkMonitor: NWPathMonitor(),
            sessionProvider: sessionProvider,
            backgroundTaskManager: backgroundTaskManager,
            osNotificationCenter: OSNotificationCenter(
                notifications: CFNotificationCenterGetDarwinNotifyCenter()
            )
        )
    }

    init(
        space: Space,
        apollo: ApolloClientProtocol,
        operations: SyncOperationFactory,
        lastRefresh: LastRefresh,
        slateService: SlateService,
        networkMonitor: NetworkPathMonitor,
        sessionProvider: SessionProvider,
        backgroundTaskManager: BackgroundTaskManager,
        osNotificationCenter: OSNotificationCenter
    ) {
        self.space = space
        self.apollo = apollo
        self.operations = operations
        self.lastRefresh = lastRefresh
        self.slateService = slateService
        self.networkMonitor = networkMonitor
        self.retrySignal = .init()
        self.sessionProvider = sessionProvider
        self.backgroundTaskManager = backgroundTaskManager
        self.osNotificationCenter = osNotificationCenter
        self.initialDownloadState = .init(.unknown)

        if lastRefresh.lastRefresh != nil {
            initialDownloadState.send(.completed)
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

    public var mainContext: NSManagedObjectContext {
        space.context
    }

    public func clear() {
        lastRefresh.reset()
        try? space.clear()
    }

    public func makeItemsController() -> SavedItemsController {
        FetchedSavedItemsController(
            resultsController: space.makeItemsController()
        )
    }

    public func makeArchiveService() -> ArchiveService {
        PocketArchiveService(apollo: apollo, space: space)
    }

    public func makeUndownloadedImagesController() -> ImagesController {
        FetchedImagesController(resultsController: space.makeUndownloadedImagesController())
    }

    public func object<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        space.object(with: id)
    }

    public func refresh(_ object: NSManagedObject, mergeChanges: Bool) {
        space.refresh(object, mergeChanges: mergeChanges)
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
}

// MARK: - MyList/Archive items
extension PocketSource {
    public func refresh(maxItems: Int = 400, completion: (() -> Void)? = nil) {
        if lastRefresh.lastRefresh == nil {
            initialDownloadState.send(.started)
        }

        guard let token = sessionProvider.session?.accessToken else {
            completion?()
            return
        }

        let operation = operations.fetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: _events,
            initialDownloadState: initialDownloadState,
            maxItems: maxItems,
            lastRefresh: lastRefresh
        )

        enqueue(operation: operation, task: .fetchList(maxItems: maxItems), completion: completion)
    }

    public func favorite(item: SavedItem) {
        guard let remoteID = item.remoteID else {
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

    public func unfavorite(item: SavedItem) {
        guard let remoteID = item.remoteID else {
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

    public func delete(item savedItem: SavedItem) {
        guard let remoteID = savedItem.remoteID else {
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

    public func archive(item: SavedItem) {
        guard let remoteID = item.remoteID else {
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

    public func unarchive(item: SavedItem) {
        guard let url = item.url else { return }

        item.isArchived = false
        item.createdAt = Date()
        try? space.save()

        let operation = operations.saveItemOperation(
            managedItemID: item.objectID,
            url: url,
            events: _events,
            apollo: apollo,
            space: space
        )

        enqueue(operation: operation, task: .save(localID: item.objectID.uriRepresentation(), url: url))
    }

    public func save(item: SavedItem) {
        guard let url = item.url else {
            return
        }

        let operation = operations.saveItemOperation(
            managedItemID: item.objectID,
            url: url,
            events: _events,
            apollo: apollo,
            space: space
        )
        enqueue(operation: operation, task: .save(localID: item.objectID.uriRepresentation(), url: url))
    }

    public func addTags(item: SavedItem, tags: [String]) {
        guard let remoteID = item.remoteID else {
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

    public func deleteTag(tag: Tag) {
        guard let remoteID = tag.remoteID else { return }

        try? space.deleteTag(byID: remoteID)
        try? space.save()

        let operation = operations.savedItemMutationOperation(
            apollo: apollo,
            events: _events,
            mutation: DeleteTagMutation(id: remoteID)
        )

        enqueue(operation: operation, task: .deleteTag(remoteID: remoteID))
    }

    public func renameTag(from oldTag: Tag, to name: String) {
        guard let remoteID = oldTag.remoteID else { return }

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

    public func retrieveTags(excluding tags: [String]) -> [Tag]? {
        try? space.retrieveTags(excluding: tags)
    }

    public func fetchAllTags() -> [Tag]? {
        try? space.fetchAllTags()
    }

    public func fetchTags(isArchived: Bool = false) -> [Tag]? {
        try? space.fetchTags(isArchived: isArchived)
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

        try space.context.performAndWait {
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
        guard let item = recommendation.item,
              let remoteID = item.remoteID else {
            return
        }

        guard let remoteItem = try await apollo
            .fetch(query: ItemByIDQuery(id: remoteID))
            .data?.itemByItemId?.fragments.itemParts else {
            return
        }

        try space.context.performAndWait {
            item.update(remote: remoteItem)
            try space.save()
        }
    }
}

// MARK: - Enqueueing and Restoring offline operations
extension PocketSource {
    private func enqueue(operation: SyncOperation, task: SyncTask, completion: (() -> Void)? = nil) {
        let persistentTask: PersistentSyncTask = space.new()
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
            self?.space.context.performAndWait { [weak self] in
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
            case .fetchList(let maxItems):
                guard let token = sessionProvider.session?.accessToken else { return }
                let operation = operations.fetchList(
                    token: token,
                    apollo: apollo,
                    space: space,
                    events: _events,
                    initialDownloadState: initialDownloadState,
                    maxItems: maxItems,
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
        guard let notifications = try? space.fetchSavedItemUpdatedNotifications() else {
            return
        }

        let updatedSavedItems = Set(notifications.compactMap(\.savedItem))
        space.delete(notifications)
        try? space.save()

        _events.send(.savedItemsUpdated(updatedSavedItems))
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
        guard let item = recommendation.item, item.bestURL != nil else {
            return
        }

        if let savedItem = recommendation.item?.savedItem {
            unarchive(item: savedItem)
        } else {
            let savedItem: SavedItem = space.new()
            savedItem.update(from: recommendation)
            try? space.save()

            save(item: savedItem)
        }
    }

    public func archive(recommendation: Recommendation) {
        guard let savedItem = recommendation.item?.savedItem, savedItem.isArchived == false else {
            return
        }

        archive(item: savedItem)
    }

    public func remove(recommendation: Recommendation) {
        space.delete(recommendation)
        try? space.save()
    }
}

// MARK: - Image
extension PocketSource {
    public func download(images: [Image]) {
        images.forEach {
            $0.isDownloaded = true
        }

        try? space.save()
    }
}

// MARK: - URL
extension PocketSource {
    public func save(url: URL) {
        if let savedItem = try? space.fetchSavedItem(byURL: url) {
            unarchive(item: savedItem)
        } else {
            let savedItem: SavedItem = space.new()
            savedItem.url = url
            savedItem.createdAt = Date()
            try? space.save()

            save(item: savedItem)
        }
    }
}
