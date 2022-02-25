import Combine
import Apollo


class SavedItemMutationOperation<Mutation: GraphQLMutation>: SyncOperation {
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

    func execute() async -> SyncOperationResult {
        do {
            _ = try await apollo.perform(mutation: mutation)
            return .success
        } catch {
            switch error {
            case is URLSessionClient.URLSessionClientError:
                return .retry
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    return .retry
                default:
                    return .failure(error)
                }
            default:
                Crashlogger.capture(error: error)
                events.send(.error(error))
                return .failure(error)
            }
        }
    }
}
