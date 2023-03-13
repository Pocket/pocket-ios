import Foundation
import Apollo
import Combine
import CoreData
import PocketGraph
import SharedPocketKit

protocol SyncOperationFactory {
    func fetchSaves(
        user: User,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation

    func fetchArchive(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation

    func savedItemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) -> SyncOperation

    func savedItemMutationOperation(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: AnyMutation
    ) -> SyncOperation

    func saveItemOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> SyncOperation
}

class OperationFactory: SyncOperationFactory {
    func fetchSaves(
        user: User,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        return FetchSaves(
            user: user,
            apollo: apollo,
            space: space,
            events: events,
            initialDownloadState: initialDownloadState,
            lastRefresh: lastRefresh
        )
    }

    func fetchArchive(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        return FetchArchive(
            apollo: apollo,
            space: space,
            events: events,
            initialDownloadState: initialDownloadState,
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

    func savedItemMutationOperation(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: AnyMutation
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
}
