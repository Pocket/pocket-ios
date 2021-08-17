// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import Apollo
import Combine


public class Source {
    public let syncEvents: PassthroughSubject<SyncEvent, Never> = PassthroughSubject()

    private let space: Space
    private let apollo: ApolloClientProtocol

    private let operations: SyncOperationFactory
    private let syncQ: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    public convenience init(
        sessionProvider: SessionProvider,
        accessTokenProvider: AccessTokenProvider,
        consumerKey: String
    ) {
        self.init(
            space: Space(container: .createDefault()),
            apollo: ApolloClient.createDefault(
                sessionProvider: sessionProvider,
                accessTokenProvider: accessTokenProvider,
                consumerKey: consumerKey
            ),
            operations: OperationFactory()
        )
    }

    init(
        space: Space,
        apollo: ApolloClientProtocol,
        operations: SyncOperationFactory
    ) {
        self.space = space
        self.apollo = apollo
        self.operations = operations
    }

    public var mainContext: NSManagedObjectContext {
        space.context
    }

    public func refresh(token: String, maxItems: Int = 400) {
        syncQ.addOperation(
            operations.fetchList(
                token: token,
                apollo: apollo,
                space: space,
                events: syncEvents,
                maxItems: maxItems
            )
        )
    }

    public func favorite(item: Item) {
        guard let itemID = item.itemID else {
            return
        }

        item.isFavorite = true
        try? space.save()

        let mutation = FavoriteItemMutation(itemID: itemID)
        let operation = operations.itemMutationOperation(
            apollo: apollo,
            events: syncEvents,
            mutation: mutation
        )

        syncQ.addOperation(operation)
    }

    public func unfavorite(item: Item) {
        guard let itemID = item.itemID else {
            return
        }

        item.isFavorite = false
        try? space.save()

        let mutation = UnfavoriteItemMutation(itemID: itemID)
        let operation = operations.itemMutationOperation(
            apollo: apollo,
            events: syncEvents,
            mutation: mutation
        )

        syncQ.addOperation(operation)
    }

    public func delete(item: Item) {
        guard let itemID = item.itemID else {
            return
        }

        space.delete(item)
        try? space.save()

        let mutation = DeleteItemMutation(itemID: itemID)
        let operation = operations.itemMutationOperation(
            apollo: apollo,
            events: syncEvents,
            mutation: mutation
        )

        syncQ.addOperation(operation)
    }

    public func archive(item: Item) {
        guard let itemID = item.itemID else {
            return
        }

        space.delete(item)
        try? space.save()

        let mutation = ArchiveItemMutation(itemID: itemID)
        let operation = operations.itemMutationOperation(
            apollo: apollo,
            events: syncEvents,
            mutation: mutation
        )

        syncQ.addOperation(operation)
    }

    public func clear() {
        try? space.clear()
    }
}
