import XCTest
import Apollo
import Combine
import CoreData

@testable import Sync


class SaveItemOperationTests: XCTestCase {
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

    func performOperation(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents? = nil,
        apollo: ApolloClientProtocol? = nil,
        space: Space? = nil
    ) {
        let operation = SaveItemOperation(
            managedItemID: managedItemID,
            url: url,
            events: events ?? self.events,
            apollo: apollo ?? self.apollo,
            space: space ?? self.space
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

    func test_main_performsSaveItemMutation_andUpdatesLocalStorage() throws {
        apollo.stubPerform(
            toReturnFixtureNamed: "save-item",
            asResultType: SaveItemMutation.self
        )

        let url = URL(string: "http://example.com/add-me-to-your-list")!
        let savedItem: SavedItem = space.new()
        savedItem.url = url
        savedItem.item = space.new()
        savedItem.item?.givenURL = url
        try space.context.performAndWait {
            try space.save()
        }

        performOperation(managedItemID: savedItem.objectID, url: url)

        let performCall: MockApolloClient.PerformCall<SaveItemMutation>? = apollo.performCall(at: 0)
        XCTAssertNotNil(performCall)
        XCTAssertEqual(performCall?.mutation.input.url, url.absoluteString)

        let item = try space.fetchSavedItem(byRemoteID: "saved-item-1")
        XCTAssertEqual(savedItem.item?.resolvedURL, URL(string: "https://resolved.example.com/item-1")!)
        XCTAssertNotNil(item)
    }

    func test_main_whenMutationFails_sendsErrorEvent() throws {
        apollo.stubPerform(
            ofMutationType: SaveItemMutation.self,
            toReturnError: TestError.anError
        )

        let url = URL(string: "http://example.com/add-me-to-your-list")!
        let expectation = self.expectation(description: "expect an event")
        events.sink { event in
            expectation.fulfill()

            guard case let .error(error) = event else {
                XCTFail("Incorrect event sent - expected .error")
                return
            }

            XCTAssertEqual(error as? TestError, TestError.anError)
        }.store(in: &subscriptions)

        let savedItem: SavedItem = space.new()
        savedItem.url = url
        savedItem.item = space.new()
        savedItem.item?.givenURL = url
        try space.save()

        performOperation(managedItemID: savedItem.objectID, url: url)

        wait(for: [expectation], timeout: 1)
    }
}
