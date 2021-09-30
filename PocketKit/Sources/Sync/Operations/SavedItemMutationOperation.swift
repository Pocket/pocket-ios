import Combine
import Apollo


class SavedItemMutationOperation<Mutation: GraphQLMutation>: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let events: SyncEvents
    private let mutation: Mutation

    init(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) {
        self.apollo = apollo
        self.events = events
        self.mutation = mutation
    }

    override func main() {
        _ = apollo.perform(
            mutation: mutation,
            publishResultToStore: false,
            queue: .main
        ) { [weak self] result in
            if case .failure(let error) = result {
                self?.events.send(.error(error))
            }

            self?.finishOperation()
        }
    }
}
