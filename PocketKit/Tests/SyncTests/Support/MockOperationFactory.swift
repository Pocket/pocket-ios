import Foundation
import Apollo
import Combine
import CoreData

@testable import Sync


class MockOperationFactory: SyncOperationFactory {
    private var implementations: [String: Any] = [:]

    // MARK: - fetchList
    struct FetchListCall {
        let token: String
        let apollo: ApolloClientProtocol
        let space: Space
        let events: SyncEvents
        let maxItems: Int
        let lastRefresh: LastRefresh
    }
    private var fetchListCalls: [FetchListCall] = []
    func fetchListCall(at index: Int) -> FetchListCall? {
        guard index < fetchListCalls.count else {
            return nil
        }

        return fetchListCalls[index]
    }

    typealias FetchListImpl = (String, ApolloClientProtocol, Space, SyncEvents, Int) -> Operation
    private var fetchListImpl: FetchListImpl?

    func stubFetchList(impl: @escaping FetchListImpl) {
        fetchListImpl = impl
    }

    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> Operation {
        fetchListCalls.append(FetchListCall(token: token, apollo: apollo, space: space, events: events, maxItems: maxItems, lastRefresh: lastRefresh))
        guard let impl = fetchListImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(token, apollo, space, events, maxItems)
    }

    // MARK: - itemMutationOperation
    typealias ItemMutationOperationImpl<Mutation: GraphQLMutation> =
        (ApolloClientProtocol, SyncEvents, Mutation) -> Operation

    private var itemMutationOperationImpls: [String: Any] = [:]

    func stubItemMutationOperation<Mutation: GraphQLMutation>(
        impl: @escaping ItemMutationOperationImpl<Mutation>
    ) {
        itemMutationOperationImpls["\(Mutation.self)"] = impl
    }

    func savedItemMutationOperation<Mutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) -> Operation where Mutation : GraphQLMutation {
        guard let impl = itemMutationOperationImpls["\(Mutation.self)"] else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        guard let typedImpl = impl as? ItemMutationOperationImpl<Mutation> else {
            fatalError("Stub implementation for \(Self.self).\(#function) is incorrect type")
        }

        return typedImpl(apollo, events, mutation)
    }

    // MARK: - saveItemOperation
    typealias SaveItemOperationImpl = (NSManagedObjectID, URL, SyncEvents, ApolloClientProtocol, Space) -> Operation
    private var saveItemOperationImpl: SaveItemOperationImpl?

    func stubSaveItemOperation(_ impl: @escaping SaveItemOperationImpl) {
        saveItemOperationImpl = impl
    }

    func saveItemOperation(managedItemID: NSManagedObjectID, url: URL, events: SyncEvents, apollo: ApolloClientProtocol, space: Space) -> Operation {
        guard let impl = saveItemOperationImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(managedItemID, url, events, apollo, space)
    }
}

extension MockOperationFactory {
    static let fetchArchivePage = "fetchArchivePage"
    typealias FetchArchivedPageImpl = (ApolloClientProtocol, Space, String, String?, Bool?) -> Operation

    func stubFetchArchivePage(impl: FetchArchivedPageImpl?) {
        implementations[Self.fetchArchivePage] = impl
    }

    func fetchArchivePage(apollo: ApolloClientProtocol, space: Space, accessToken: String, cursor: String?, isFavorite: Bool?) -> Operation {
        guard let impl = implementations[Self.fetchArchivePage] as? FetchArchivedPageImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        return impl(apollo, space, accessToken, cursor, isFavorite)
    }
}
