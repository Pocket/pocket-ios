import Foundation
import Apollo
import Combine

@testable import Sync


class MockOperationFactory: SyncOperationFactory {

    // MARK: - favoriteItem
    typealias FavoriteItemImpl = (Space, ApolloClientProtocol, String, PassthroughSubject<SyncEvent, Never>) -> Operation
    private var favoriteItemImpl: FavoriteItemImpl?

    func stubFavoriteItem(impl: @escaping FavoriteItemImpl) {
        favoriteItemImpl = impl
    }

    func favoriteItem(space: Space, apollo: ApolloClientProtocol, itemID: String, events: PassthroughSubject<SyncEvent, Never>) -> Operation {
        guard let impl = favoriteItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(space, apollo, itemID, events)
    }

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

    // MARK: - unfavoriteItem

    typealias UnfavoriteItemImpl = (Space, ApolloClientProtocol, String, PassthroughSubject<SyncEvent, Never>) -> Operation
    private var unfavoriteItemImpl: UnfavoriteItemImpl?

    func stubUnfavoriteItem(impl: @escaping UnfavoriteItemImpl) {
        unfavoriteItemImpl = impl
    }

    func unfavoriteItem(
        space: Space,
        apollo: ApolloClientProtocol,
        itemID: String,
        events: PassthroughSubject<SyncEvent, Never>
    ) -> Operation {
        guard let impl = unfavoriteItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(space, apollo, itemID, events)
    }

    // MARK: - deleteItem
    typealias DeleteItemImpl = (ApolloClientProtocol, PassthroughSubject<SyncEvent, Never>, String) -> Operation
    private var deleteItemImpl: DeleteItemImpl?

    func stubDeleteItem(impl: @escaping DeleteItemImpl) {
        deleteItemImpl = impl
    }

    func deleteItem(apollo: ApolloClientProtocol, events: PassthroughSubject<SyncEvent, Never>, itemID: String) -> Operation {
        guard let impl = deleteItemImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return impl(apollo, events, itemID)
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
