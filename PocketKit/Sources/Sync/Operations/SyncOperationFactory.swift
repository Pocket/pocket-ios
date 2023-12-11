// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import CoreData
import PocketGraph
import SharedPocketKit

protocol SyncOperationFactory {
    func fetchSaves(
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

    func fetchTags(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        lastRefresh: LastRefresh
    ) -> SyncOperation

    func fetchSharedWithYouHighlights(
        apollo: ApolloClientProtocol,
        space: Space,
        sharedWithYouHighlights: [PocketSWHighlight]
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
        url: String,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> SyncOperation
}

class OperationFactory: SyncOperationFactory {
    func fetchSaves(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        return FetchSaves(
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

    func fetchTags(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        return FetchTags(
            apollo: apollo,
            space: space,
            events: events,
            lastRefresh: lastRefresh
        )
    }

    func fetchSharedWithYouHighlights(
        apollo: ApolloClientProtocol,
        space: Space,
        sharedWithYouHighlights: [PocketSWHighlight]
    ) -> SyncOperation {
        return FetchSharedWithYouHighlights(
            apollo: apollo,
            space: space,
            sharedWithYouHighlights: sharedWithYouHighlights
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
        url: String,
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

    func getUserData(
        apollo: ApolloClientProtocol,
        user: User
    ) -> SyncOperation {
        APIUserService(
            apollo: apollo,
            user: user
        ) as! SyncOperation
    }
}
