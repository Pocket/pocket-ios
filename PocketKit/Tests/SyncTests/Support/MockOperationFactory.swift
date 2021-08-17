import Foundation
import Apollo
import Combine

@testable import Sync


class MockOperationFactory: SyncOperationFactory {

    // MARK: - fetchList
    typealias FetchListImpl = (String, ApolloClientProtocol, Space, PassthroughSubject<SyncEvent, Never>, Int) -> Operation
    private var fetchListImpl: FetchListImpl?

    func stubFetchList(impl: @escaping FetchListImpl) {
        fetchListImpl = impl
    }

    func fetchList(token: String, apollo: ApolloClientProtocol, space: Space, events: PassthroughSubject<SyncEvent, Never>, maxItems: Int) -> Operation {
        guard let impl = fetchListImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(token, apollo, space, events, maxItems)
    }

    // MARK: - itemMutationOperation
    typealias ItemMutationOperationImpl<Mutation: GraphQLMutation> =
        (ApolloClientProtocol, PassthroughSubject<SyncEvent, Never>, Mutation) -> Operation

    private var itemMutationOperationImpls: [String: Any] = [:]

    func stubItemMutationOperation<Mutation: GraphQLMutation>(
        impl: @escaping ItemMutationOperationImpl<Mutation>
    ) {
        itemMutationOperationImpls["\(Mutation.self)"] = impl
    }

    func itemMutationOperation<Mutation>(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
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
}
