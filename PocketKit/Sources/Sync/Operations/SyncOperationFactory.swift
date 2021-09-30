import Foundation
import Apollo
import Combine
import CoreData


protocol SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> Operation

    func savedItemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) -> Operation

    func saveItemOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> Operation
}

class OperationFactory: SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> Operation {
        return FetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: events,
            maxItems: maxItems,
            lastRefresh: lastRefresh
        )
    }

    func savedItemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) -> Operation {
        SavedItemMutationOperation(apollo: apollo, events: events, mutation: mutation)
    }

    func saveItemOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> Operation {
        SaveItemOperation(
            managedItemID: managedItemID,
            url: url,
            events: events,
            apollo: apollo,
            space: space
        )
    }
}
