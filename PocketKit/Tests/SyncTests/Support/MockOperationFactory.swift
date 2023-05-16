import Foundation
import Apollo
import ApolloAPI
import Combine
import CoreData
import SharedPocketKit

@testable import Sync

class MockOperationFactory: SyncOperationFactory {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
    private var lock: DispatchQueue = DispatchQueue(label: "")
}

// MARK: - fetchSaves
extension MockOperationFactory {
    typealias FetchSavesImpl = (
        ApolloClientProtocol,
        Space,
        SyncEvents,
        CurrentValueSubject<InitialDownloadState, Never>
    ) -> SyncOperation

    struct FetchSavesCall {
        let apollo: ApolloClientProtocol
        let space: Space
        let events: SyncEvents
        let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
        let lastRefresh: LastRefresh
    }

    func stubFetchSaves(impl: @escaping FetchSavesImpl) {
        implementations["fetchSaves"] = impl
    }

    func fetchSaves(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        guard let impl = implementations["fetchSaves"] as? FetchSavesImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        lock.sync {
            calls["fetchSaves"] = (calls["fetchSaves"] ?? []) + [
                FetchSavesCall(
                    apollo: apollo,
                    space: space,
                    events: events,
                    initialDownloadState: initialDownloadState,
                    lastRefresh: lastRefresh
                )
            ]
        }

        return impl(apollo, space, events, initialDownloadState)
    }

    func fetchSavesCall(at index: Int) -> FetchSavesCall? {
        guard let fetchSavesCalls = calls["fetchSaves"], index < fetchSavesCalls.count else {
            return nil
        }

        return fetchSavesCalls[index] as? FetchSavesCall
    }
}

// MARK: - fetchArchive
extension MockOperationFactory {
    typealias FetchArchiveImpl = (
        ApolloClientProtocol,
        Space,
        SyncEvents,
        CurrentValueSubject<InitialDownloadState, Never>
    ) -> SyncOperation

    struct FetchArchiveCall {
        let apollo: ApolloClientProtocol
        let space: Space
        let events: SyncEvents
        let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
        let lastRefresh: LastRefresh
    }

    func stubFetchArchive(impl: @escaping FetchArchiveImpl) {
        implementations["fetchArchive"] = impl
    }

    func fetchArchive(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        guard let impl = implementations["fetchArchive"] as? FetchArchiveImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        lock.sync {
            calls["fetchArchive"] = (calls["fetchArchive"] ?? []) + [
                FetchArchiveCall(
                    apollo: apollo,
                    space: space,
                    events: events,
                    initialDownloadState: initialDownloadState,
                    lastRefresh: lastRefresh
                )
            ]
        }

        return impl(apollo, space, events, initialDownloadState)
    }

    func fetchArchiveCall(at index: Int) -> FetchArchiveCall? {
        guard let fetchArchiveCalls = calls["fetchArchive"], index < fetchArchiveCalls.count else {
            return nil
        }

        return fetchArchiveCalls[index] as? FetchArchiveCall
    }
}

// MARK: - fetchSharedWithYouHighlights
extension MockOperationFactory {
    typealias FetchSharedWithYouHighlightsImpl = (
        ApolloClientProtocol,
        Space,
        [Sync.PocketSWHighlight]
    ) -> SyncOperation

    struct FetchSharedWithYouHighlightsCall {
        let apollo: ApolloClientProtocol
        let space: Space
        let sharedWithYouHighlights: [Sync.PocketSWHighlight]
    }

    func stubFetchSharedWithYouHighlights(impl: @escaping FetchArchiveImpl) {
        implementations["fetchSharedWithYouHighlights"] = impl
    }

    func fetchSharedWithYouHighlights(apollo: Apollo.ApolloClientProtocol, space: Sync.Space, sharedWithYouHighlights: [Sync.PocketSWHighlight]) -> Sync.SyncOperation {
        guard let impl = implementations["fetchSharedWithYouHighlights"] as? FetchSharedWithYouHighlightsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        lock.sync {
            calls["fetchSharedWithYouHighlights"] = (calls["fetchSharedWithYouHighlights"] ?? []) + [
                FetchSharedWithYouHighlightsCall(
                    apollo: apollo,
                    space: space,
                    sharedWithYouHighlights: sharedWithYouHighlights
                )
            ]
        }

        return impl(apollo, space, sharedWithYouHighlights)
    }

    func fetchSharedWithYouHighlightsCall(at index: Int) -> FetchSharedWithYouHighlightsCall? {
        guard let fetchSharedWithYouHighlightsCalls = calls["fetchSharedWithYouHighlights"], index < fetchSharedWithYouHighlightsCalls.count else {
            return nil
        }

        return fetchSharedWithYouHighlightsCalls[index] as? FetchSharedWithYouHighlightsCall
    }
}

// MARK: - fetchTags
extension MockOperationFactory {
    typealias FetchTagsImpl = (
        ApolloClientProtocol,
        Space,
        SyncEvents
    ) -> SyncOperation

    struct FetchTagsCall {
        let apollo: ApolloClientProtocol
        let space: Space
        let events: SyncEvents
        let lastRefresh: LastRefresh
    }

    func stubFetchTags(impl: @escaping FetchTagsImpl) {
        implementations["fetchTags"] = impl
    }

    func fetchTags(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        guard let impl = implementations["fetchTags"] as? FetchTagsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls["fetchTags"] = (calls["fetchTags"] ?? []) + [
            FetchTagsCall(
                apollo: apollo,
                space: space,
                events: events,
                lastRefresh: lastRefresh
            )
        ]

        return impl(apollo, space, events)
    }

    func fetchTagsCall(at index: Int) -> FetchTagsCall? {
        guard let fetchTagsCalls = calls["fetchTags"], index < fetchTagsCalls.count else {
            return nil
        }

        return fetchTagsCalls[index] as? FetchTagsCall
    }
}

// MARK: - itemMutationOperation
extension MockOperationFactory {
    typealias ItemMutationOperationImpl<Mutation: GraphQLMutation> = (
        ApolloClientProtocol,
        SyncEvents,
        Mutation
    ) -> SyncOperation

    func stubItemMutationOperation<Mutation: GraphQLMutation>(
        impl: @escaping ItemMutationOperationImpl<Mutation>
    ) {
        implementations["itemMutationOperation<\(Mutation.self)>"] = impl
    }

    func savedItemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) -> SyncOperation {
        guard let impl = implementations["itemMutationOperation<\(Mutation.self)>"] as? ItemMutationOperationImpl<Mutation> else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(apollo, events, mutation)
    }
}

// MARK: - itemAnyMutationOperation (without generics)
extension MockOperationFactory {
    typealias ItemAnyMutationOperationImpl = (
        ApolloClientProtocol,
        SyncEvents,
        AnyMutation
    ) -> SyncOperation

    func stubItemAnyMutationOperation(
        impl: @escaping ItemAnyMutationOperationImpl
    ) {
        implementations["itemAnyMutationOperation"] = impl
    }

    func savedItemMutationOperation(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: AnyMutation
    ) -> SyncOperation {
        guard let impl = implementations["itemAnyMutationOperation"] as? ItemAnyMutationOperationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(apollo, events, mutation)
    }
}

// MARK: - saveItemOperation
extension MockOperationFactory {
    typealias SaveItemOperationImpl = (NSManagedObjectID, URL, SyncEvents, ApolloClientProtocol, Space) -> SyncOperation

    func stubSaveItemOperation(_ impl: @escaping SaveItemOperationImpl) {
        implementations["saveItemOperation"] = impl
    }

    func saveItemOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents,
        apollo: ApolloClientProtocol,
        space: Space
    ) -> SyncOperation {
        guard let impl = implementations["saveItemOperation"] as? SaveItemOperationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(managedItemID, url, events, apollo, space)
    }
}
