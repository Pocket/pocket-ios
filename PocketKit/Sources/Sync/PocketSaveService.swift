import Foundation
import Apollo


public class PocketSaveService: SaveService {
    private let apollo: ApolloClientProtocol
    private let expiringActivityPerformer: ExpiringActivityPerformer
    private let queue: OperationQueue
    private let space: Space
    private let osNotifications: OSNotificationCenter

    public convenience init(
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
            space: Space(container: .init(storage: .shared)),
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

    public func save(url: URL) {
        expiringActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.save") { [weak self] expiring in
            self?._save(expiring: expiring, url: url)
        }
    }

    private func _save(expiring: Bool, url: URL) {
        guard !expiring else {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
            return
        }

        let operation = SaveOperation(
            apollo: apollo,
            osNotifications: osNotifications,
            space: space,
            url: url
        )

        queue.addOperation(operation)
        queue.waitUntilAllOperationsAreFinished()
    }
}

class SaveOperation: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let osNotifications: OSNotificationCenter
    private let space: Space
    private let url: URL

    private var task: Cancellable?
    private var savedItem: SavedItem?

    init(
        apollo: ApolloClientProtocol,
        osNotifications: OSNotificationCenter,
        space: Space,
        url: URL
    ) {
        self.apollo = apollo
        self.osNotifications = osNotifications
        self.space = space
        self.url = url
    }

    override func start() {
        guard !isCancelled else { return }

        storeLocalSkeletonItem()
        performMutation()
    }

    override func cancel() {
        task?.cancel()
        finishOperation()

        storeUnresolvedSavedItem()
        super.cancel()
    }

    private func storeLocalSkeletonItem() {
        savedItem = space.new()
        savedItem?.url = url
        savedItem?.createdAt = Date()
        try? space.save()

        osNotifications.post(name: .savedItemCreated)
    }

    private func performMutation() {
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

        savedItem?.update(from: savedItemParts)
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
