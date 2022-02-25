import XCTest
import Apollo


extension MockApolloClient {
    func stubPerform<T: GraphQLMutation>(
        toReturnFixtureNamed fixtureName: String,
        asResultType: T.Type,
        handler: (() -> ())? = nil
    ) {
        stubPerform { (mutation: T, _, queue, completion) in
            queue.async {
                let data = Fixture
                    .load(name: fixtureName)
                    .asGraphQLResult(from: mutation)

                completion?(.success(data))
                handler?()
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
            queue.async {
                completion?(.failure(error))
                handler?()
            }

            return MockCancellable()
        }
    }

    func stubFetch<T: GraphQLQuery>(
        toReturnFixturedNamed fixtureName: String,
        asResultType resultType: T.Type,
        handler: (() -> ())? = nil
    ) {
        stubFetch(
            toReturnFixture: Fixture.load(name: fixtureName),
            asResultType: resultType,
            handler: handler
        )
    }

    func stubFetch<T: GraphQLQuery>(
        toReturnFixture fixture: Fixture,
        asResultType: T.Type,
        handler: (() -> ())? = nil
    ) {
        stubFetch { (query: T, _, _, queue, completion) -> Apollo.Cancellable in
            queue.async {
                completion?(.success(fixture.asGraphQLResult(from: query)))
                handler?()
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
            queue.async {
                completion?(.failure(error))
                handler?()
            }

            return MockCancellable()
        }
    }
}
