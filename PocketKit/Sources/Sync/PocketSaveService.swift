import Foundation
import Apollo

public class PocketSaveService: SaveService {
    private let apollo: ApolloClientProtocol
    private let expiringActivityPerformer: ExpiringActivityPerformer
    private let queue: OperationQueue
    private let space: Space
    private let osNotifications: OSNotificationCenter

    public convenience init(
        space: Space,
        sessionProvider: SessionProvider,
        consumerKey: String,
        expiringActivityPerformer: ExpiringActivityPerformer
    ) {
        self.init(
            apollo: ApolloClient.createDefault(
                sessionProvider: sessionProvider,
                consumerKey: consumerKey
            ),
            expiringActivityPerformer: expiringActivityPerformer,
            space: space,
            osNotifications: OSNotificationCenter(
                notifications: CFNotificationCenterGetDarwinNotifyCenter()
            )
        )
    }

    init(
        apollo: ApolloClientProtocol,
        expiringActivityPerformer: ExpiringActivityPerformer,
        space: Space,
        osNotifications: OSNotificationCenter
    ) {
        self.apollo = apollo
        self.expiringActivityPerformer = expiringActivityPerformer
        self.space = space
        self.osNotifications = osNotifications

        self.queue = OperationQueue()
    }

    public func save(url: URL) -> SaveServiceStatus {
        let result = fetchOrCreateSavedItem(url: url)

        expiringActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.save") { [weak self] expiring in
            self?._save(expiring: expiring, savedItem: result.savedItem)
        }

        return result.status
    }

    private func fetchOrCreateSavedItem(url: URL) -> (savedItem: SavedItem, status: SaveServiceStatus) {
        if let existingItem = try! space.fetchSavedItem(byURL: url) {
            existingItem.createdAt = Date()

            let notification: SavedItemUpdatedNotification = space.new()
            notification.savedItem = existingItem
            try? space.save()

            osNotifications.post(name: .savedItemUpdated)
            return (existingItem, .existingItem)
        } else {
            let savedItem: SavedItem = space.new()
            savedItem.url = url
            savedItem.createdAt = Date()
            try? space.save()

            osNotifications.post(name: .savedItemCreated)
            return (savedItem, .newItem)
        }
    }

    private func _save(expiring: Bool, savedItem: SavedItem) {
        guard !expiring else {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
            return
        }

        let operation = SaveOperation(
            apollo: apollo,
            osNotifications: osNotifications,
            space: space,
            savedItem: savedItem
        )

        queue.addOperation(operation)
        queue.waitUntilAllOperationsAreFinished()
    }
}

class SaveOperation: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let osNotifications: OSNotificationCenter
    private let space: Space
    private let savedItem: SavedItem

    private var task: Cancellable?

    init(
        apollo: ApolloClientProtocol,
        osNotifications: OSNotificationCenter,
        space: Space,
        savedItem: SavedItem
    ) {
        self.apollo = apollo
        self.osNotifications = osNotifications
        self.space = space
        self.savedItem = savedItem
    }

    override func start() {
        guard !isCancelled else { return }
        performMutation()
    }

    override func cancel() {
        task?.cancel()
        finishOperation()

        storeUnresolvedSavedItem()
        super.cancel()
    }

    private func performMutation() {
        guard let url = savedItem.url else { return }

        let mutation = SaveItemMutation(input: SavedItemUpsertInput(url: url.absoluteString))
        task = apollo.perform(mutation: mutation, publishResultToStore: false, queue: .main) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<GraphQLResult<SaveItemMutation.Data>, Error>) {
        guard case .success(let graphQLResult) = result,
              let savedItemParts = graphQLResult.data?.upsertSavedItem.fragments.savedItemParts else {
            storeUnresolvedSavedItem()
            finishOperation()
            return
        }

        savedItem.update(from: savedItemParts, with: space)
        let notification: SavedItemUpdatedNotification = space.new()
        notification.savedItem = savedItem
        try? space.save()

        osNotifications.post(name: .savedItemUpdated)
        finishOperation()
    }

    private func storeUnresolvedSavedItem() {
        let unresolved: UnresolvedSavedItem = space.new()
        unresolved.savedItem = savedItem
        try? space.save()

        osNotifications.post(name: .unresolvedSavedItemCreated)
    }
}

public extension CFNotificationName {
    static let savedItemCreated = CFNotificationName("com.mozilla.pocket.savedItemCreated" as CFString)
    static let savedItemUpdated = CFNotificationName("com.mozilla.pocket.savedItemUpdated" as CFString)
    static let unresolvedSavedItemCreated = CFNotificationName("com.mozilla.pocket.unresolvedSavedItemCreated" as CFString)
}
