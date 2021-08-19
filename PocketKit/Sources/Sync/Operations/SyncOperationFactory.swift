import Foundation
import Apollo
import Combine


protocol SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> Operation

    func itemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
        mutation: Mutation
    ) -> Operation
}

class OperationFactory: SyncOperationFactory {
    func fetchList(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) -> Operation {
        return FetchList(
            token: token,
            apollo: apollo,
            space: space,
            events: events,
            maxItems: maxItems,
            lastRefresh: lastRefresh
        )
    }

    func itemMutationOperation<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
        mutation: Mutation
    ) -> Operation {
        ItemMutationOperation(apollo: apollo, events: events, mutation: mutation)
    }
}
