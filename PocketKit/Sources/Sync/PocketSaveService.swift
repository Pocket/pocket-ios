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
    private let recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService

    public convenience init(
        space: Space,
        sessionProvider: SessionProvider,
        consumerKey: String,
        expiringActivityPerformer: ExpiringActivityPerformer,
        recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService
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
            ),
            recentSavesWidgetUpdateService: recentSavesWidgetUpdateService
        )
    }

    init(
        apollo: ApolloClientProtocol,
        expiringActivityPerformer: ExpiringActivityPerformer,
        space: Space,
        osNotifications: OSNotificationCenter,
        recentSavesWidgetUpdateService: RecentSavesWidgetUpdateService
    ) {
        self.apollo = apollo
        self.expiringActivityPerformer = expiringActivityPerformer
        self.space = space
        self.osNotifications = osNotifications
        self.recentSavesWidgetUpdateService = recentSavesWidgetUpdateService

        self.queue = OperationQueue()
    }

    public func save(url: URL) -> SaveServiceStatus {
        defer {
            reloadRecentSavesWidget()
        }
        return space.performAndWait {
            let result = fetchOrCreateSavedItem(url: url)

            expiringActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.save") { [weak self] expiring in
                self?._save(expiring: expiring, savedItem: result.savedItem)
            }

            return result
        }
    }

    public func retrieveTags(excluding tags: [String]) -> [Tag]? {
        try? space.retrieveTags(excluding: tags)
    }

    public func filterTags(with input: String, excluding tags: [String]) -> [Tag]? {
        try? space.filterTags(with: input, excluding: tags)
    }

    public func addTags(savedItem: SavedItem, tags: [String]) -> SaveServiceStatus {
        return space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
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
            let notification: SavedItemUpdatedNotification = SavedItemUpdatedNotification(context: space.backgroundContext)
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

                let notification: SavedItemUpdatedNotification = SavedItemUpdatedNotification(context: space.backgroundContext)
                notification.savedItem = existingItem

                try? space.save()

                osNotifications.post(name: .savedItemUpdated)
                return .existingItem(existingItem)
            } else {
                let savedItem: SavedItem = SavedItem(context: space.backgroundContext, url: url)
                savedItem.url = url
                savedItem.createdAt = Date()
                try? space.save()

                osNotifications.post(name: .savedItemCreated)
                return .newItem(savedItem)
            }
        }
    }

    private func _addTags(expiring: Bool, savedItem: SavedItem) {
        space.performAndWait {
            guard !expiring else {
                queue.cancelAllOperations()
                queue.waitUntilAllOperationsAreFinished()
                return
            }
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for _addTags")
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
                    mutation: mutation
                ) { graphQLResultData in
                    return (graphQLResultData as? UpdateSavedItemRemoveTagsMutation.Data)?.updateSavedItemRemoveTags.fragments.savedItemParts
                }
                queue.addOperation(operation)
            } else {
                let mutation = ReplaceSavedItemTagsMutation(input: [SavedItemTagsInput(savedItemId: remoteID, tags: names)])

                let operation = SaveOperation<ReplaceSavedItemTagsMutation>(
                    apollo: apollo,
                    osNotifications: osNotifications,
                    space: space,
                    savedItem: savedItem,
                    mutation: mutation
                ) { graphQLResultData in
                    return (graphQLResultData as? ReplaceSavedItemTagsMutation.Data)?.replaceSavedItemTags.first?.fragments.savedItemParts
                }
                queue.addOperation(operation)
            }
        }
        queue.waitUntilAllOperationsAreFinished()
    }

    private func _save(expiring: Bool, savedItem: SavedItem) {
        space.performAndWait {
            guard !expiring else {
                queue.cancelAllOperations()
                queue.waitUntilAllOperationsAreFinished()
                return
            }

            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
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

    private func reloadRecentSavesWidget() {
        do {
            let recentSaves = try space.fetchSavedItems(limit: SyncConstants.Home.recentSaves)
            recentSavesWidgetUpdateService.update(recentSaves, Localization.recentSaves)
        } catch {
            Log.capture(message: "Unable to update the Recent Saves widget after saving an item from the Save extension - \(error)")
        }
    }
}

class SaveOperation<Mutation: GraphQLMutation>: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let osNotifications: OSNotificationCenter
    private let space: Space
    private let savedItem: SavedItem
    private let mutation: any GraphQLMutation
    private let savedItemParts: (any RootSelectionSet) -> SavedItemParts?

    private var task: Cancellable?

    init(
        apollo: ApolloClientProtocol,
        osNotifications: OSNotificationCenter,
        space: Space,
        savedItem: SavedItem,
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

    private func performMutation<Mutation: GraphQLMutation>(mutation: Mutation) {
        task = apollo.perform(mutation: mutation, publishResultToStore: false, queue: .global(qos: .userInitiated)) { [weak self] result in
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
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
                Log.capture(message: "Save Service could not get a savedItem from the background context, for update")
                return
            }
            savedItem.update(from: savedItemParts, with: space)
            let notification: SavedItemUpdatedNotification = SavedItemUpdatedNotification(context: space.backgroundContext)
            notification.savedItem = savedItem
            try? space.save()
        }
        osNotifications.post(name: .savedItemUpdated)
        finishOperation()
    }

    private func storeUnresolvedSavedItem() {
        try? space.performAndWait {
            guard let savedItem = space.backgroundObject(with: savedItem.objectID) as? SavedItem else {
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
