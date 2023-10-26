// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import ApolloAPI
@testable import Sync

class MockApolloClient: ApolloClientProtocol {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
    private var lock: DispatchQueue = DispatchQueue(label: "")
}

// MARK: - fetch
extension MockApolloClient {
    private static let fetch = "fetch"

    struct FetchCall<Query: GraphQLQuery> {
        let query: Query
        let cachePolicy: CachePolicy
        let contextIdentifier: UUID?
        let context: RequestContext?
        let queue: DispatchQueue
    }

    typealias FetchImpl<Query: GraphQLQuery> = (
        Query,
        CachePolicy,
        UUID?,
        RequestContext?,
        DispatchQueue,
        GraphQLResultHandler<Query.Data>?
    ) -> Cancellable

    @discardableResult
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy,
        contextIdentifier: UUID?,
        context: RequestContext?,
        queue: DispatchQueue,
        resultHandler: GraphQLResultHandler<Query.Data>? = nil
    ) -> Cancellable {
        let functionID = "\(Self.fetch)<\(Query.self)>"

        guard let anyImpl = implementations[functionID] else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        guard let impl = anyImpl as? FetchImpl<Query> else {
            fatalError("Stub implementation for \(Self.self).\(#function) is incorrect type")
        }

        lock.sync {
            calls[functionID] = (calls[functionID] ?? []) + [
                FetchCall(
                    query: query,
                    cachePolicy: cachePolicy,
                    contextIdentifier: contextIdentifier,
                    context: context,
                    queue: queue
                )
            ]
        }

        return impl(query, cachePolicy, contextIdentifier, context, queue, resultHandler)
    }

    func stubFetch<Query: GraphQLQuery>(impl: @escaping FetchImpl<Query>) {
        let functionID = "\(Self.fetch)<\(Query.self)>"
        implementations[functionID] = impl
    }

    func fetchCall<Query: GraphQLQuery>(at index: Int) -> FetchCall<Query>? {
        let functionID = "\(Self.fetch)<\(Query.self)>"

        guard let calls = calls[functionID], calls.count > index else {
            return nil
        }

        let anyCall = calls[index]
        guard let call = anyCall as? MockApolloClient.FetchCall<Query> else {
            fatalError("Call is incorrect type: \(anyCall)")
        }

        return call
    }

    func fetchCall<Query: GraphQLQuery>(
        withQueryType queryType: Query.Type,
        at index: Int
    ) -> FetchCall<Query>? {
        return fetchCall(at: index)
    }

    func fetchCalls<Query: GraphQLQuery>(withQueryType: Query.Type) -> [FetchCall<Query>] {
        let functionID = "\(Self.fetch)<\(Query.self)>"
        return (calls[functionID] ?? []).compactMap { $0 as? FetchCall<Query> }
    }
}

// MARK: - perform
extension MockApolloClient {
    private static let perform = "perform"

    struct PerformCall<Mutation: GraphQLMutation> {
        let mutation: Mutation
        let publishResultToStore: Bool
        let queue: DispatchQueue
        let context: RequestContext?
        let resultHandler: GraphQLResultHandler<Mutation.Data>?
    }

    typealias PerformImpl<Mutation: GraphQLMutation> = (
        Mutation,
        Bool,
        DispatchQueue,
        GraphQLResultHandler<Mutation.Data>?
    ) -> Cancellable

    @discardableResult
    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool,
        context: RequestContext?,
        queue: DispatchQueue,
        resultHandler: GraphQLResultHandler<Mutation.Data>?
    ) -> Cancellable {
        let functionID = "\(Self.perform)<\(Mutation.self)>"

        guard let anyImpl = implementations[functionID] else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        guard let impl = anyImpl as? PerformImpl<Mutation> else {
            fatalError("Stub implementation for \(Self.self).\(#function) is incorrect type")
        }

        lock.sync {
            calls[functionID] = (calls[functionID] ?? []) + [
                PerformCall(
                    mutation: mutation,
                    publishResultToStore: publishResultToStore,
                    queue: queue,
                    context: context,
                    resultHandler: resultHandler
                )
            ]
        }

        return impl(mutation, publishResultToStore, queue, resultHandler)
    }

    func stubPerform<Mutation: GraphQLMutation>(impl: @escaping PerformImpl<Mutation>) {
        let functionID = "\(Self.perform)<\(Mutation.self)>"
        implementations[functionID] = impl
    }

    func performCall<Mutation: GraphQLMutation>(at index: Int) -> PerformCall<Mutation>? {
        let functionID = "\(Self.perform)<\(Mutation.self)>"

        guard let calls = calls[functionID], calls.count > index else {
            return nil
        }

        let anyCall = calls[index]
        guard let call = anyCall as? MockApolloClient.PerformCall<Mutation> else {
            fatalError("Call is incorrect type: \(anyCall)")
        }

        return call
    }

    func performCall<Mutation: GraphQLMutation>(
        withMutationType mutationType: Mutation.Type,
        at index: Int
    ) -> PerformCall<Mutation>? {
        return performCall(at: index)
    }
}

// MARK: - not implemented
extension MockApolloClient {
    var store: ApolloStore {
        fatalError("\(Self.self).\(#function) is not implemented")
    }

    @discardableResult
    func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy,
        context: Apollo.RequestContext?,
        callbackQueue: DispatchQueue,
        resultHandler: @escaping GraphQLResultHandler<Query.Data>
    ) -> GraphQLQueryWatcher<Query> {
        fatalError("\(Self.self).\(#function) is not implemented")
    }

    @discardableResult
    func upload<Operation: GraphQLOperation>(
        operation: Operation, 
        files: [Apollo.GraphQLFile],
        context: Apollo.RequestContext?,
        queue: DispatchQueue, resultHandler:
        Apollo.GraphQLResultHandler<Operation.Data>?
    ) -> Cancellable {
        fatalError("\(Self.self).\(#function) is not implemented")
    }

    @discardableResult
    func subscribe<Subscription: GraphQLSubscription>(
        subscription: Subscription,
        context: RequestContext?,
        queue: DispatchQueue,
        resultHandler: @escaping GraphQLResultHandler<Subscription.Data>
    ) -> Cancellable {
        fatalError("\(Self.self).\(#function) is not implemented")
    }

    func clearCache(callbackQueue: DispatchQueue, completion: ((Result<Void, Error>) -> Void)?) {
        fatalError("\(Self.self).\(#function) is not implemented")
    }
}
