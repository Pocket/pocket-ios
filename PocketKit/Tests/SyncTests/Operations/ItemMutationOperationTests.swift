import XCTest
import Apollo
import ApolloAPI
import PocketGraph
import Combine

@testable import Sync

class ItemMutationOperationTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var subscriptions: [AnyCancellable] = []
    var queue: OperationQueue!
    var events: SyncEvents!

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        space = .testSpace()
        queue = OperationQueue()
        events = PassthroughSubject()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func subject<Mutation: GraphQLMutation>(
        mutation: Mutation,
        apollo: ApolloClientProtocol? = nil,
        events: SyncEvents? = nil
    ) -> SavedItemMutationOperation {
        SavedItemMutationOperation(
            apollo: apollo ?? self.apollo,
            events: events ?? self.events,
            mutation: mutation
        )
    }

    func test_operation_performsGivenMutation() async throws {
        try space.createSavedItem(remoteID: "test-item-id")

        apollo.stubPerform(
            toReturnFixtureNamed: "archive",
            asResultType: ArchiveItemMutation.self
        )

        let mutation = ArchiveItemMutation(itemID: "test-item-id")
        let service = subject(mutation: mutation)
        _ = await service.execute()

        let call = apollo.performCall(
            withMutationType: ArchiveItemMutation.self,
            at: 0
        )

        XCTAssertEqual(call?.mutation.itemID, "test-item-id")
    }

    func test_operation_whenMutationFails_propagatesError() async throws {
        try space.createSavedItem()

        apollo.stubPerform(
            ofMutationType: ArchiveItemMutation.self,
            toReturnError: TestError.anError
        )

        var error: Error?
        events.sink { event in
            guard case .error(let e) = event else {
                return
            }

            error = e
        }.store(in: &subscriptions)

        let mutation = ArchiveItemMutation(itemID: "test-item-id")
        let service = subject(mutation: mutation)
        _ = await service.execute()

        XCTAssertNotNil(error)
        XCTAssertEqual(error as? TestError, .anError)
    }

    func test_execute_whenMutationFailsWithHTTP5XX_retries() async throws {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        apollo.stubPerform(ofMutationType: ArchiveItemMutation.self, toReturnError: initialError)

        let mutation = ArchiveItemMutation(itemID: "test-item-id")
        let service = subject(mutation: mutation)
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }

    func test_execute_whenClientSideNetworkFails_retries() async throws {
        let initialError = URLSessionClient.URLSessionClientError.networkError(
            data: Data(),
            response: nil,
            underlying: TestError.anError
        )

        apollo.stubPerform(ofMutationType: ArchiveItemMutation.self, toReturnError: initialError)

        let mutation = ArchiveItemMutation(itemID: "test-item-id")
        let service = subject(mutation: mutation)
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }
}
