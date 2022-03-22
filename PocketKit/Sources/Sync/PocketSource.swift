// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine
import Network


public typealias SyncEvents = PassthroughSubject<SyncEvent, Never>

public class PocketSource: Source {
    private let _events: SyncEvents = PassthroughSubject()
    public var events: AnyPublisher<SyncEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    private let space: Space
    private let apollo: ApolloClientProtocol
    private let lastRefresh: LastRefresh
    private let slateService: SlateService
    private let networkMonitor: NetworkPathMonitor
    private let retrySignal: PassthroughSubject<Void, Never>
    private let sessionProvider: SessionProvider
    private let backgroundTaskManager: BackgroundTaskManager

    private let operations: SyncOperationFactory
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public convenience init(
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
            space: Space(container: .createDefault()),
            apollo: apollo,
            operations: OperationFactory(),
            lastRefresh: UserDefaultsLastRefresh(defaults: defaults),
            slateService: APISlateService(apollo: apollo),
            networkMonitor: NWPathMonitor(),
            sessionProvider: sessionProvider,
            backgroundTaskManager: backgroundTaskManager
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
        backgroundTaskManager: BackgroundTaskManager
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

        observeNetworkStatus()
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

    public func object<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        space.object(with: id)
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
    public func refresh(maxItems: Int = 400, completion: (() -> ())? = nil) {
        guard let token = sessionProvider.session?.accessToken else {
            completion?()
            return
        }

        let operation = operations.fetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: _events,
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

    public func delete(item: SavedItem) {
        guard let remoteID = item.remoteID else {
            return
        }

        space.delete(item)
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
        try? space.save()

        let operation = operations.savedItemMutationOperation(
            apollo: apollo,
            events: _events,
            mutation: ArchiveItemMutation(itemID: remoteID)
        )

        enqueue(operation: operation, task: .archive(remoteID: remoteID))
    }

    public func unarchive(item: SavedItem) {
        guard let remoteID = item.remoteID else {
            return
        }

        item.isArchived = false
        try? space.save()

        let operation = operations.savedItemMutationOperation(
            apollo: apollo,
            events: _events,
            mutation: UnarchiveItemMutation(itemID: remoteID)
        )

        enqueue(operation: operation, task: .unarchive(remoteID: remoteID))
    }
}

// MARK: - Slates/Recommendations
extension PocketSource {
    public func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup? {
        return try await slateService.fetchSlateLineup(identifier)
    }

    public func fetchSlate(_ slateID: String) async throws -> Slate? {
        return try await slateService.fetchSlate(slateID)
    }

    public func savedRecommendationsService() -> SavedRecommendationsService {
        SavedRecommendationsService(space: space)
    }

    public func save(recommendation: Slate.Recommendation) {
        guard let url = recommendation.item.resolvedURL ?? recommendation.item.givenURL else {
            return
        }

        let savedItem: SavedItem = space.new()
        savedItem.update(from: recommendation)
        try? space.save()

        let operation = operations.saveItemOperation(
            managedItemID: savedItem.objectID,
            url: url,
            events: _events,
            apollo: apollo,
            space: space
        )

        let task = SyncTask.save(localID: savedItem.objectID.uriRepresentation(), url: url)
        enqueue(operation: operation, task: task)
    }

    public func archive(recommendation: Slate.Recommendation) {
        guard let savedItem = try? space.fetchSavedItem(byRemoteItemID: recommendation.item.id) else {
            return
        }

        archive(item: savedItem)
    }
}

// MARK: - Archived Items
extension PocketSource {
    public func fetchArchivePage(cursor: String?, isFavorite: Bool?) {
        guard let accessToken = sessionProvider.session?.accessToken else {
            return
        }

        let operation = operations.fetchArchivePage(
            apollo: apollo,
            space: space,
            accessToken: accessToken,
            cursor: cursor,
            isFavorite: isFavorite
        )

        enqueue(operation: operation, task: .fetchArchivePage(cursor: cursor, isFavorite: isFavorite)) { [weak self] in
            self?._events.send(.loadedArchivePage)
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
            case .unarchive(let remoteID):
                let operation = operations.savedItemMutationOperation(
                    apollo: apollo,
                    events: _events,
                    mutation: UnarchiveItemMutation(itemID: remoteID)
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
            case let .fetchArchivePage(cursor, isFavorite):
                guard let token = sessionProvider.session?.accessToken else { return }

                let operation = operations.fetchArchivePage(
                    apollo: apollo,
                    space: space,
                    accessToken: token,
                    cursor: cursor,
                    isFavorite: isFavorite
                )
                enqueue(operation: operation, persistentTask: persistentTask)
            }
        }
    }
}
