import Foundation
import Apollo
import ApolloAPI
import Combine
import CoreData

@testable import Sync

class MockOperationFactory: SyncOperationFactory {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: - fetchList
extension MockOperationFactory {
    typealias FetchListImpl = (
        String,
        ApolloClientProtocol,
        Space,
        SyncEvents,
        CurrentValueSubject<InitialDownloadState, Never>,
        Int
    ) -> SyncOperation

    struct FetchListCall {
        let token: String
        let apollo: ApolloClientProtocol
        let space: Space
        let events: SyncEvents
        let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
        let maxItems: Int
        let lastRefresh: LastRefresh
    }

    func stubFetchList(impl: @escaping FetchListImpl) {
        implementations["fetchList"] = impl
    }

    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> SyncOperation {
        guard let impl = implementations["fetchList"] as? FetchListImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls["fetchList"] = (calls["fetchList"] ?? []) + [
            FetchListCall(
                token: token,
                apollo: apollo,
                space: space,
                events: events,
                initialDownloadState: initialDownloadState,
                maxItems: maxItems,
                lastRefresh: lastRefresh
            )
        ]

        return impl(token, apollo, space, events, initialDownloadState, maxItems)
    }

    func fetchListCall(at index: Int) -> FetchListCall? {
        guard let fetchListCalls = calls["fetchList"], index < fetchListCalls.count else {
            return nil
        }

        return fetchListCalls[index] as? FetchListCall
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
