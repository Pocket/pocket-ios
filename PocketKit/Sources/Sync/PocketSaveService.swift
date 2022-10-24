import Foundation
import Apollo
import PocketGraph

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

        return result
    }

    public func retrieveTags(excluding tags: [String]) -> [Tag]? {
        try? space.retrieveTags(excluding: tags)
    }

    public func addTags(savedItem: SavedItem, tags: [String]) -> SaveServiceStatus {
        savedItem.tags = NSOrderedSet(array: tags.compactMap { $0 }.map({ tag in
            space.fetchOrCreateTag(byName: tag)
        }))

       try? space.save()

        osNotifications.post(name: .savedItemUpdated)

        expiringActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.addTags") { [weak self] expiring in
            self?._addTags(expiring: expiring, savedItem: savedItem)
        }

        return .taggedItem(savedItem)
    }

    private func fetchOrCreateSavedItem(url: URL) -> SaveServiceStatus {
        if let existingItem = try! space.fetchSavedItem(byURL: url) {
            existingItem.createdAt = Date()

            let notification: SavedItemUpdatedNotification = space.new()
            notification.savedItem = existingItem

            try? space.save()

            osNotifications.post(name: .savedItemUpdated)
            return .existingItem(existingItem)
        } else {
            let savedItem: SavedItem = space.new()
            savedItem.url = url
            savedItem.createdAt = Date()
            try? space.save()

            osNotifications.post(name: .savedItemCreated)
            return .newItem(savedItem)
        }
    }

    private func _addTags(expiring: Bool, savedItem: SavedItem) {
        guard !expiring else {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
            return
        }

        guard let tags = savedItem.tags, let remoteID = savedItem.remoteID else { return }
        let names = Array(tags).compactMap { ($0 as? Tag)?.name }

        if names.isEmpty {
            let mutation = UpdateSavedItemRemoveTagsMutation(savedItemId: remoteID)

            let operation = SaveOperation<UpdateSavedItemRemoveTagsMutation>(
                apollo: apollo,
                osNotifications: osNotifications,
                space: space,
                savedItem: savedItem,
                mutation: mutation) { graphQLResultData in
                    return (graphQLResultData as? UpdateSavedItemRemoveTagsMutation.Data)?.updateSavedItemRemoveTags.fragments.savedItemParts
                }
            queue.addOperation(operation)
            queue.waitUntilAllOperationsAreFinished()
        } else {
            let mutation = ReplaceSavedItemTagsMutation(input: [SavedItemTagsInput(savedItemId: remoteID, tags: names)])

            let operation = SaveOperation<ReplaceSavedItemTagsMutation>(
                apollo: apollo,
                osNotifications: osNotifications,
                space: space,
                savedItem: savedItem,
                mutation: mutation) { graphQLResultData in
                    return (graphQLResultData as? ReplaceSavedItemTagsMutation.Data)?.replaceSavedItemTags.first?.fragments.savedItemParts
                }
            queue.addOperation(operation)
            queue.waitUntilAllOperationsAreFinished()
        }
    }

    private func _save(expiring: Bool, savedItem: SavedItem) {
        guard !expiring else {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
            return
        }

        guard let url = savedItem.url else { return }
        let mutation =  SaveItemMutation(input: SavedItemUpsertInput(url: url.absoluteString))

        let operation = SaveOperation<SaveItemMutation>(
            apollo: apollo,
            osNotifications: osNotifications,
            space: space,
            savedItem: savedItem,
            mutation: mutation) { graphQLResultData in
                return (graphQLResultData as? SaveItemMutation.Data)?.upsertSavedItem.fragments.savedItemParts
            }

        queue.addOperation(operation)
        queue.waitUntilAllOperationsAreFinished()
    }
}

class SaveOperation<Mutation: GraphQLMutation>: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let osNotifications: OSNotificationCenter
    private let space: Space
    private let savedItem: SavedItem
    private let mutation: any GraphQLMutation
    private let savedItemParts: (AnySelectionSet) -> SavedItemParts?

    private var task: Cancellable?

    init(
        apollo: ApolloClientProtocol,
        osNotifications: OSNotificationCenter,
        space: Space,
        savedItem: SavedItem,
        mutation: Mutation,
        savedItemParts: @escaping (AnySelectionSet) -> SavedItemParts?
    ) {
        self.apollo = apollo
        self.osNotifications = osNotifications
        self.space = space
        self.savedItem = savedItem
        self.mutation = mutation
        self.savedItemParts = savedItemParts
    }

    override func start() {
        guard !isCancelled else { return }
        performMutation(mutation: mutation)
    }

    override func cancel() {
        task?.cancel()
        finishOperation()

        storeUnresolvedSavedItem()
        super.cancel()
    }

    private func performMutation<Mutation: GraphQLMutation>(mutation: Mutation) {
        task = apollo.perform(mutation: mutation, publishResultToStore: false, queue: .main) { [weak self] result in
            guard case .success(let graphQLResult) = result,
                    let data = graphQLResult.data,
                    let savedItemParts = self?.savedItemParts(data) else {
                self?.storeUnresolvedSavedItem()
                self?.finishOperation()
                return
            }
            self?.updateSavedItem(savedItemParts: savedItemParts)
        }
    }

    private func updateSavedItem(savedItemParts: SavedItemParts) {
        savedItem.update(from: savedItemParts, with: space)
        let notification: SavedItemUpdatedNotification = space.new()
        notification.savedItem = savedItem
        try? space.save()

        osNotifications.post(name: .savedItemUpdated)
        finishOperation()
    }

    private func storeUnresolvedSavedItem() {
        try? space.context.performAndWait {
            let unresolved: UnresolvedSavedItem = space.new()
            unresolved.savedItem = savedItem
            try space.save()
        }

        osNotifications.post(name: .unresolvedSavedItemCreated)
    }
}

public extension CFNotificationName {
    static let savedItemCreated = CFNotificationName("com.mozilla.pocket.savedItemCreated" as CFString)
    static let savedItemUpdated = CFNotificationName("com.mozilla.pocket.savedItemUpdated" as CFString)
    static let unresolvedSavedItemCreated = CFNotificationName("com.mozilla.pocket.unresolvedSavedItemCreated" as CFString)
}
