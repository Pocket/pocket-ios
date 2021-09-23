// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Apollo


class ItemMutationOperation<Mutation: GraphQLMutation>: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let events: PassthroughSubject<SyncEvent, Never>
    private let mutation: Mutation

    init(
        apollo: ApolloClientProtocol,
        events: PassthroughSubject<SyncEvent, Never>,
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
