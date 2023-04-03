// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Apollo
import ApolloAPI

class AnyMutation {
    let perform: (ApolloClientProtocol) async throws -> Void
    init<Mutation: GraphQLMutation>(_ mutation: Mutation) {
        perform = { apollo in
            _ = try await apollo.perform(mutation: mutation)
        }
    }
}

class SavedItemMutationOperation: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let events: SyncEvents
    private let mutation: AnyMutation

    init<Mutation: GraphQLMutation>(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: Mutation
    ) {
        self.apollo = apollo
        self.events = events
        self.mutation = AnyMutation(mutation)
    }

    init(
        apollo: ApolloClientProtocol,
        events: SyncEvents,
        mutation: AnyMutation
    ) {
        self.apollo = apollo
        self.events = events
        self.mutation = mutation
    }

    func execute() async -> SyncOperationResult {
        do {
            _ = try await mutation.perform(apollo)
            return .success
        } catch {
            switch error {
            case is URLSessionClient.URLSessionClientError:
                return .retry(error)
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    return .retry(error)
                default:
                    return .failure(error)
                }
            default:
                Log.capture(error: error)
                events.send(.error(error))
                return .failure(error)
            }
        }
    }
}
