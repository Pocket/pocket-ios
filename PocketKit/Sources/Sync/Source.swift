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
        mutate(item, FavoriteItemMutation.init) { item in
            item.isFavorite = true
        }
    }

    public func unfavorite(item: Item) {
        mutate(item, UnfavoriteItemMutation.init) { item in
            item.isFavorite = false
        }
    }

    public func delete(item: Item) {
        mutate(item, DeleteItemMutation.init) { item in
            space.delete(item)
        }
    }

    public func archive(item: Item) {
        mutate(item, ArchiveItemMutation.init) { item in
            space.delete(item)
        }
    }

    public func clear() {
        try? space.clear()
    }

    private func mutate<Mutation: GraphQLMutation>(
        _ item: Item,
        _ remoteMutation: (String) -> Mutation,
        localMutation: (Item) -> ()
    ) {
        guard let itemID = item.itemID else {
            return
        }

        localMutation(item)
        try? space.save()

        let operation = operations.itemMutationOperation(
            apollo: apollo,
            events: syncEvents,
            mutation: remoteMutation(itemID)
        )

        syncQ.addOperation(operation)
    }
}
