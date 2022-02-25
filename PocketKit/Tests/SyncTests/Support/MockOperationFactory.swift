import Foundation
import Apollo
import Combine
import CoreData

@testable import Sync


class MockOperationFactory: SyncOperationFactory {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: - fetchList
extension MockOperationFactory {
    typealias FetchListImpl = (String, ApolloClientProtocol, Space, SyncEvents, Int) -> SyncOperation

    struct FetchListCall {
        let token: String
        let apollo: ApolloClientProtocol
        let space: Space
        let events: SyncEvents
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
                maxItems: maxItems,
                lastRefresh: lastRefresh
            )
        ]

        return impl(token, apollo, space, events, maxItems)
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

// MARK: fetchArchivePage
extension MockOperationFactory {
    static let fetchArchivePage = "fetchArchivePage"
    typealias FetchArchivedPageImpl = (ApolloClientProtocol, Space, String, String?, Bool?) -> SyncOperation

    func stubFetchArchivePage(impl: FetchArchivedPageImpl?) {
        implementations[Self.fetchArchivePage] = impl
    }

    func fetchArchivePage(
        apollo: ApolloClientProtocol,
        space: Space,
        accessToken: String,
        cursor: String?,
        isFavorite: Bool?
    ) -> SyncOperation {
        guard let impl = implementations[Self.fetchArchivePage] as? FetchArchivedPageImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        return impl(apollo, space, accessToken, cursor, isFavorite)
    }
}
