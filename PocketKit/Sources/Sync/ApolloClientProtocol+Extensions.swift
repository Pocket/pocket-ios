// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo


extension ApolloClientProtocol {
    func fetch<Query: GraphQLQuery>(query: Query, resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
        return fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely,
            contextIdentifier: nil,
            queue: .main,
            resultHandler: resultHandler
        )
    }
}
