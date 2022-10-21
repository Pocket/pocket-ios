// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import ApolloAPI

public extension ApolloClientProtocol {
    func fetch<Query: GraphQLQuery>(query: Query, resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
        return fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely,
            contextIdentifier: nil,
            queue: .main,
            resultHandler: resultHandler
        )
    }

    func fetch<Query: GraphQLQuery>(query: Query) async throws -> GraphQLResult<Query.Data> {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GraphQLResult<Query.Data>, Error>) in
            _ = fetch(query: query) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let data):
                    continuation.resume(returning: data)
                }
            }
        }
    }

    func perform<Mutation: GraphQLMutation>(mutation: Mutation) async throws -> GraphQLResult<Mutation.Data> {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GraphQLResult<Mutation.Data>, Error>) in
            _ = perform(
                mutation: mutation,
                publishResultToStore: false,
                queue: .main
            ) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let data):
                    continuation.resume(returning: data)
                }
            }
        }
    }
}
