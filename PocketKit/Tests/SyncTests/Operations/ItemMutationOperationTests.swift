import XCTest
import Apollo
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
        space = Space(container: .testContainer)
        queue = OperationQueue()
        events = PassthroughSubject()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func performOperation<Mutation: GraphQLMutation>(
        mutation: Mutation,
        apollo: ApolloClientProtocol? = nil,
        events: SyncEvents? = nil
    ) {
        let operation = SavedItemMutationOperation(
            apollo: apollo ?? self.apollo,
            events: events ?? self.events,
            mutation: mutation
        )

        let expectationToCompleteOperation = expectation(
            description: "Expect operation to complete"
        )

        operation.completionBlock = {
            expectationToCompleteOperation.fulfill()
        }

        queue.addOperation(operation)

        wait(for: [expectationToCompleteOperation], timeout: 1)
    }

    func test_operation_performsGivenMutation() throws {
        try space.seedSavedItem(remoteID: "test-item-id")

        apollo.stubPerform(
            toReturnFixtureNamed: "archive",
            asResultType: ArchiveItemMutation.self
        )

        let mutation = ArchiveItemMutation(itemID: "test-item-id")
        performOperation(mutation: mutation)

        let call = apollo.performCall(
            withMutationType: ArchiveItemMutation.self,
            at: 0
        )

        XCTAssertEqual(call?.mutation.itemID, "test-item-id")
    }

    func test_operation_whenMutationFails_propagatesError() throws {
        try space.seedSavedItem()

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
        performOperation(mutation: mutation)

        XCTAssertNotNil(error)
        XCTAssertEqual(error as? TestError, .anError)
    }
}
