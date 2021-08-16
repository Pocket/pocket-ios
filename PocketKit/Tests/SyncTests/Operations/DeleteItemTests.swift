import XCTest
import Combine
import Apollo

@testable import Sync


class DeleteItemTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var subscriptions: [AnyCancellable] = []
    var queue: OperationQueue!
    var events: PassthroughSubject<SyncEvent, Never>!

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

    func performOperation(
        apollo: ApolloClientProtocol? = nil,
        itemID: String = "test-item-id",
        events: PassthroughSubject<SyncEvent, Never>? = nil
    ) {
        let operation = DeleteItem(
            apollo: apollo ?? self.apollo,
            events: events ?? self.events,
            itemID: itemID
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

    func tests_deleteItem_sendsDeleteItemMutation() throws {
        try space.seedItem()
        apollo.stubPerform(toReturnFixtureNamed: "delete", asResultType: DeleteItemMutation.self)

        performOperation()

        let call = apollo.performCall(
            withMutationType: DeleteItemMutation.self,
            at: 0
        )

        XCTAssertEqual(call?.mutation.itemID, "test-item-id")
    }

    func test_deleteItem_whenMutationFails_sendsError() throws {
        try space.seedItem()

        apollo.stubPerform(
            ofMutationType: DeleteItemMutation.self,
            toReturnError: TestError.anError
        )

        var error: Error?
        events.sink { event in
            guard case .error(let e) = event else {
                return
            }

            error = e
        }.store(in: &subscriptions)

        performOperation()

        XCTAssertNotNil(error)
        XCTAssertEqual(error as? TestError, .anError)
    }


}
