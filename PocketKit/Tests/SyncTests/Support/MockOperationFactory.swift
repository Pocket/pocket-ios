// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine

@testable import Sync


class MockOperationFactory: SyncOperationFactory {

    // MARK: - fetchList
    struct FetchListCall {
        let token: String
        let apollo: ApolloClientProtocol
        let space: Space
        let events: PassthroughSubject<SyncEvent, Never>
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

    typealias FetchListImpl = (String, ApolloClientProtocol, Space, PassthroughSubject<SyncEvent, Never>, Int) -> Operation
    private var fetchListImpl: FetchListImpl?

    func stubFetchList(impl: @escaping FetchListImpl) {
        fetchListImpl = impl
    }

    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
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
