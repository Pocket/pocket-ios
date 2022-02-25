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
    ) -> SyncOperation

    func savedItemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) -> SyncOperation

    func saveItemOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> SyncOperation

    func fetchArchivePage(
        apollo: ApolloClientProtocol,
        space: Space,
        accessToken: String,
        cursor: String?,
        isFavorite: Bool?
    ) -> SyncOperation
}

class OperationFactory: SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
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
    ) -> SyncOperation {
        SavedItemMutationOperation(apollo: apollo, events: events, mutation: mutation)
    }

    func saveItemOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> SyncOperation {
        SaveItemOperation(
            managedItemID: managedItemID,
            url: url,
            events: events,
            apollo: apollo,
            space: space
        )
    }

    func fetchArchivePage(
        apollo: ApolloClientProtocol,
        space: Space,
        accessToken: String,
        cursor: String?,
        isFavorite: Bool?
    ) -> SyncOperation {
        FetchArchivePageOperation(
            apollo: apollo,
            space: space,
            accessToken: accessToken,
            cursor: cursor,
            isFavorite: isFavorite
        )
    }
}
