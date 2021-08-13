import XCTest
import Apollo


extension MockApolloClient {
    func stubPerform<T: GraphQLMutation>(
        toReturnFixtureNamed fixtureName: String,
        asResultType: T.Type,
        handler: (() -> ())? = nil
    ) {
        stubPerform { (mutation: T, _, queue, completion) in
            defer { handler?() }

            let data = Fixture
                .load(name: fixtureName)
                .asGraphQLResult(from: mutation)

            queue.async {
                completion?(.success(data))
            }

            return MockCancellable()
        }
    }

    func stubPerform<T: GraphQLMutation>(
        ofMutationType: T.Type,
        toReturnError error: Error,
        handler: (() -> ())? = nil
    ) {
        stubPerform { (mutation: T, _, queue, completion) -> Apollo.Cancellable in
            defer { handler?() }

            queue.async {
                completion?(.failure(error))
            }

            return MockCancellable()
        }
    }

    func stubFetch<T: GraphQLQuery>(
        toReturnFixturedNamed fixtureName: String,
        asResultType: T.Type,
        handler: (() -> ())? = nil
    ) {
        stubFetch { (query: T, _, _, queue, completion) -> Apollo.Cancellable in
            defer { handler?() }

            let result = Fixture
                .load(name: fixtureName)
                .asGraphQLResult(from: query)

            queue.async {
                completion?(.success(result))
            }

            return MockCancellable()
        }
    }

    func stubFetch<T: GraphQLQuery>(
        ofQueryType: T.Type,
        toReturnError error: Error,
        handler: (() -> ())? = nil
    ) {
        stubFetch { (query: T, _, _, queue, completion) -> Apollo.Cancellable in
            defer { handler?() }

            queue.async {
                completion?(.failure(error))
            }

            return MockCancellable()
        }
    }
}
