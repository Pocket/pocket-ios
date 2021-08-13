import XCTest
import Combine
import Apollo

@testable import Sync


class UnfavoriteItemTests: XCTestCase {
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
        space: Space? = nil,
        apollo: ApolloClientProtocol? = nil,
        itemID: String = "test-item-id",
        events: PassthroughSubject<SyncEvent, Never>? = nil
    ) {
        let operation = UnfavoriteItem(
            space: space ?? self.space,
            apollo: apollo ?? self.apollo,
            itemID: itemID,
            events: events ?? self.events
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


    func test_unfavoriteItem_sendsUnfavoriteMutation_andUpdatesLocalStorage() throws {
        try space.seedItem()
        apollo.stubPerform(toReturnFixtureNamed: "unfavorite", asResultType: UnfavoriteItemMutation.self)

        performOperation()

        let call: MockApolloClient.PerformCall<UnfavoriteItemMutation>? = apollo.performCall(at: 0)
        XCTAssertEqual(call?.mutation.itemID, "test-item-id")
    }

    func test_unfavoriteItem_whenMutationFails_publishesError() throws {
        try space.seedItem()
        apollo.stubPerform(ofMutationType: UnfavoriteItemMutation.self, toReturnError: TestError.anError)

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
