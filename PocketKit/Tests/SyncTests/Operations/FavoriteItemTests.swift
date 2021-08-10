import XCTest
import CoreData
import Combine

@testable import Sync


class FavoriteItemTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var subscriptions: [AnyCancellable] = []

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        space = Space(container: .testContainer)

        try space.clear()
    }

    override func tearDown() {
        subscriptions = []
    }

    @discardableResult
    func seedItem() throws -> Item {
        let item = space.newItem()
        item.itemID = "the-item-id"
        item.url = URL(string: "http://example.com/item-1")!
        item.title = "Item 1"
        item.isFavorite = false
        try space.save()

        return item
    }

    func performOperation(events: PassthroughSubject<SyncEvent, Never> = PassthroughSubject()) {
        let operation = FavoriteItem(
            space: space,
            apollo: apollo,
            itemID: "test-item-id",
            events: events
        )

        let expectationToCompleteOperation = expectation(
            description: "Expect operation to complete"
        )

        operation.completionBlock = {
            expectationToCompleteOperation.fulfill()
        }

        let queue = OperationQueue()
        queue.addOperation(operation)
    }

    private func configureMockClientToReturnFixture(named fixtureName: String) {
        let expectFavorite = expectation(description: "Expect a favorite item request")
        apollo.stubPerform { (mutation: FavoriteItemMutation, _, queue, completion) in
            defer { expectFavorite.fulfill() }

            XCTAssertEqual(mutation.itemID, "test-item-id")

            let data = Fixture
                .load(name: "favorite")
                .asGraphQLResult(from: mutation)

            queue.async {
                completion?(.success(data))
            }

            return MockCancellable()
        }
    }

    private func configureMockClientToFail(with error: Error) {
        let expectFavorite = expectation(description: "Expect a favorite item request")
        apollo.stubPerform { (mutation: FavoriteItemMutation, _, queue, completion) in
            defer { expectFavorite.fulfill() }

            queue.async {
                completion?(.failure(error))
            }

            return MockCancellable()
        }
    }

    func test_favoriteItem_sendsFavoriteItemMutation() throws {
        try seedItem()

        configureMockClientToReturnFixture(named: "favorite")
        performOperation()

        waitForExpectations(timeout: 1)
    }

    func test_favoriteItem_whenMutationFails_publishesError() throws {
        _ = try seedItem()
        let events = PassthroughSubject<SyncEvent, Never>()

        var error: Error?
        let expectError = expectation(description: "Expect an error")
        events.sink { event in
            guard case .error(let e) = event else {
                return
            }

            error = e
            expectError.fulfill()
        }.store(in: &subscriptions)

        configureMockClientToFail(with: TestError.anError)
        performOperation(events: events)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(error)
        XCTAssertEqual(error as? TestError, .anError)
    }
}
