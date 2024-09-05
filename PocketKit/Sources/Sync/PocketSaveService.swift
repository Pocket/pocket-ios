// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Localization
import PocketGraph
import SharedPocketKit

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

    public func save(url: String) -> SaveServiceStatus {
        return space.performAndWait {
            let result = fetchOrCreateSavedItem(url: url)

            expiringActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.save") { [weak self] expiring in
                self?._save(expiring: expiring, savedItem: result.savedItem)
            }

            return result
        }
    }

    public func retrieveTags(excluding tags: [String]) -> [CDTag]? {
        try? space.retrieveTags(excluding: tags)
    }

    public func filterTags(with input: String, excluding tags: [String]) -> [CDTag]? {
        try? space.filterTags(with: input, excluding: tags)
    }

    public func addTags(savedItem: CDSavedItem, tags: [String]) -> SaveServiceStatus {
        return space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? CDSavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for add tags")
                return .taggedItem(savedItem)
            }
            savedItem.tags = NSOrderedSet(array: tags.compactMap { $0 }.map({ tag in
                space.fetchOrCreateTag(byName: tag)
            }))

            // Adding and sending a SavedItemUpdatedNotification will trigger the app to update
            // its list for updated items from the share extension, since the context
            // used within the space, here, and that within the app (used by Saves) may be different.
            // Once the notification is posted, and these types of notifications exist within the space,
            // the app target can appropriately update from the Save extension by listener (see PocketSource.init).
            let notification: CDSavedItemUpdatedNotification = CDSavedItemUpdatedNotification(context: space.backgroundContext)
            notification.savedItem = savedItem

            try? space.save()

            osNotifications.post(name: .savedItemUpdated)

            expiringActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.addTags") { [weak self] expiring in
                self?._addTags(expiring: expiring, savedItem: savedItem)
            }

            return .taggedItem(savedItem)
        }
    }

    private func fetchOrCreateSavedItem(url: String) -> SaveServiceStatus {
        return space.performAndWait {
            if let existingItem = try? space.fetchSavedItem(byURL: url) {
                existingItem.createdAt = Date()

                let notification: CDSavedItemUpdatedNotification = CDSavedItemUpdatedNotification(context: space.backgroundContext)
                notification.savedItem = existingItem

                try? space.save()

                osNotifications.post(name: .savedItemUpdated)
                return .existingItem(existingItem)
            } else {
                let savedItem: CDSavedItem = CDSavedItem(context: space.backgroundContext, url: url)
                savedItem.url = url
                savedItem.createdAt = Date()
                try? space.save()

                osNotifications.post(name: .savedItemCreated)
                return .newItem(savedItem)
            }
        }
    }

    private func _addTags(expiring: Bool, savedItem: CDSavedItem) {
        space.performAndWait {
            guard !expiring else {
                queue.cancelAllOperations()
                queue.waitUntilAllOperationsAreFinished()
                return
            }
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? CDSavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for _addTags")
                return
            }

            guard let tags = savedItem.tags, let remoteID = savedItem.remoteID else { return }
            let names = Array(tags).compactMap { ($0 as? CDTag)?.name }

            if names.isEmpty {
                let mutation = UpdateSavedItemRemoveTagsMutation(savedItemId: remoteID)

                let operation = SaveOperation<UpdateSavedItemRemoveTagsMutation>(
                    apollo: apollo,
                    osNotifications: osNotifications,
                    space: space,
                    savedItem: savedItem,
                    mutation: mutation
                ) { graphQLResultData in
                    return (graphQLResultData as? UpdateSavedItemRemoveTagsMutation.Data)?.updateSavedItemRemoveTags.fragments.savedItemParts
                }
                queue.addOperation(operation)
            } else {
                let url = savedItem.item?.givenURL ?? savedItem.url
                let mutation = SavedItemTagMutation(
                    input: SavedItemTagInput(givenUrl: url, tagNames: names),
                    timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
                )

                let operation = SaveOperation<SavedItemTagMutation>(
                    apollo: apollo,
                    osNotifications: osNotifications,
                    space: space,
                    savedItem: savedItem,
                    mutation: mutation
                ) { graphQLResultData in
                    return (graphQLResultData as? SavedItemTagMutation.Data)?.savedItemTag?.fragments.savedItemParts
                }
                queue.addOperation(operation)
            }
        }
        queue.waitUntilAllOperationsAreFinished()
    }

    private func _save(expiring: Bool, savedItem: CDSavedItem) {
        space.performAndWait {
            guard !expiring else {
                queue.cancelAllOperations()
                queue.waitUntilAllOperationsAreFinished()
                return
            }

            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? CDSavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for _save")
                return
            }

            let mutation =  SaveItemMutation(input: SavedItemUpsertInput(url: savedItem.url))

            let operation = SaveOperation<SaveItemMutation>(
                apollo: apollo,
                osNotifications: osNotifications,
                space: space,
                savedItem: savedItem,
                mutation: mutation
            ) { graphQLResultData in
                return (graphQLResultData as? SaveItemMutation.Data)?.upsertSavedItem.fragments.savedItemParts
            }

            queue.addOperation(operation)
        }
        queue.waitUntilAllOperationsAreFinished()
    }
}

class SaveOperation<Mutation: GraphQLMutation>: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let osNotifications: OSNotificationCenter
    private let space: Space
    private let savedItem: CDSavedItem
    private let mutation: Mutation
    private let savedItemParts: (any RootSelectionSet) -> SavedItemParts?

    private var task: Cancellable?

    init(
        apollo: ApolloClientProtocol,
        osNotifications: OSNotificationCenter,
        space: Space,
        savedItem: CDSavedItem,
        mutation: Mutation,
        savedItemParts: @escaping (any RootSelectionSet) -> SavedItemParts?
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

    private func performMutation(mutation: Mutation) {
        task = apollo.perform(mutation: mutation, publishResultToStore: false, context: nil, queue: .global(qos: .userInitiated)) { [weak self] result in
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
        space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? CDSavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for update")
                return
            }
            savedItem.update(from: savedItemParts, with: space)
            let notification: CDSavedItemUpdatedNotification = CDSavedItemUpdatedNotification(context: space.backgroundContext)
            notification.savedItem = savedItem
            try? space.save()
        }
        osNotifications.post(name: .savedItemUpdated)
        finishOperation()
    }

    private func storeUnresolvedSavedItem() {
        try? space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? CDSavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for unresolved item")
                return
            }
            let unresolved: UnresolvedSavedItem = UnresolvedSavedItem(context: space.backgroundContext)
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
