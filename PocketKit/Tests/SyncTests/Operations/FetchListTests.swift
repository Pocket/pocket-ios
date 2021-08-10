import XCTest
import Combine
import CoreData
import Apollo

@testable import Sync


class FetchListTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var events: PassthroughSubject<SyncEvent, Never>!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        events = PassthroughSubject()

        space = Space(container: .testContainer)
        try space.clear()
    }

    override func tearDown() {
        cancellables = []
    }

    func performOperation(maxItems: Int = 400) {
        let operation = FetchList(
            token: "test-token",
            apollo: apollo,
            space: space,
            events: events,
            maxItems: maxItems
        )

        let expectationToCompleteOperation = expectation(
            description: "Expect operation to complete"
        )

        operation.completionBlock = {
            expectationToCompleteOperation.fulfill()
        }

        let queue = OperationQueue()
        queue.addOperation(operation)

        wait(for: [expectationToCompleteOperation], timeout: 1)
    }

    private func configureMockClientToReturnFixture(named fixtureName: String) {
        apollo.stubFetch { (query: UserByTokenQuery, _, _, queue, completion) -> Apollo.Cancellable in
            queue.async {
                let result = Fixture.load(name: fixtureName).asGraphQLResult(from: query)
                completion?(.success(result))
            }

            return MockCancellable()
        }
    }

    func test_refresh_fetchesUserByTokenQueryWithGivenToken() {
        configureMockClientToReturnFixture(named: "list")

        performOperation()

        XCTAssertFalse(apollo.fetchCalls.isEmpty)
        let call: MockApolloClient.FetchCall<UserByTokenQuery> = apollo.fetchCall(at: 0)
        XCTAssertEqual(call.query.token, "test-token")
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() throws {
        configureMockClientToReturnFixture(named: "list")

        performOperation()

        let items = try space.fetchAllItems()
        XCTAssertEqual(items.count, 2)

        do {
            let item = items[0]
            XCTAssertEqual(item.itemID, "item-id-1")
            XCTAssertTrue(item.isFavorite)
            XCTAssertEqual(item.domain, "example.com")
            XCTAssertEqual(item.domainMetadata?.name, "WIRED")
            XCTAssertEqual(item.thumbnailURL, URL(string: "https://example.com/item-1/top-image.jpg")!)
            XCTAssertEqual(item.timestamp, Date(timeIntervalSince1970: 0))
            XCTAssertEqual(item.timeToRead, 6)
            XCTAssertEqual(item.title, "Item 1")
            XCTAssertEqual(item.url, URL(string: "https://example.com/item-1")!)
            XCTAssertEqual(item.particleJSON, "<just-json-things>")
            XCTAssertEqual(item.isArchived, false)
            XCTAssertEqual(item.deletedAt, Date(timeIntervalSince1970: 1))
        }
    }

    func test_refresh_whenFetchSucceeds_andResultContainsDuplicateItems_createsSingleItem() throws {
        configureMockClientToReturnFixture(named: "duplicate-list")

        performOperation()

        let items = try space.fetchItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistingItems() throws {
        let itemURL = URL(string: "http://example.com/item-1")!

        do {
            let item = space.newItem()
            item.url = itemURL
            item.title = "Item 1"
            try space.save()
        }

        configureMockClientToReturnFixture(named: "updated-item")
        performOperation()

        let item = try space.fetchItem(byURLString: itemURL.absoluteString)
        XCTAssertEqual(item?.title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() throws {
        var error: Error?
        events.sink { event in
            guard case .error(let actualError) = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }
            error = actualError
        }.store(in: &cancellables)

        apollo.stubFetch { (query: UserByTokenQuery, _, _, queue, completion) -> Apollo.Cancellable in
            queue.async {
                completion?(.failure(TestError.anError))
            }

            return MockCancellable()
        }

        performOperation()

        XCTAssertEqual(error as? TestError, .anError)
    }

    func test_refresh_whenResponseIncludesMultiplePages_fetchesNextPage() throws {
        var fetches = 0
        apollo.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            let result: Fixture
            switch fetches {
            case 0:
                result = Fixture.load(name: "paginated-list-1")
            case 1:
                XCTAssertEqual(query.pagination?.after, "cursor-1")
                result = Fixture.load(name: "paginated-list-2")
            default:
                XCTFail("Unexpected number of fetches: \(fetches)")
                return MockCancellable()
            }

            fetches += 1
            completion?(.success(result.asGraphQLResult(from: query)))
            return MockCancellable()
        }

        performOperation()

        let items = try space.fetchItems()
        XCTAssertEqual(items.count, 2)
    }

    func test_refresh_whenItemCountExceedsMax_fetchesMaxNumberOfItems() throws {
        var fetches = 0
        apollo.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            let result: Fixture
            switch fetches {
            case 0:
                result = Fixture.load(name: "large-list-1")
            case 1:
                XCTAssertEqual(query.pagination?.after, "cursor-1")
                result = Fixture.load(name: "large-list-2")
            case 2:
                XCTAssertEqual(query.pagination?.after, "cursor-2")
                result = Fixture.load(name: "large-list-3")
            default:
                XCTFail("Unexpected number of fetches: \(fetches)")
                return MockCancellable()
            }

            fetches += 1
            completion?(.success(result.asGraphQLResult(from: query)))
            return MockCancellable()
        }

        performOperation(maxItems: 3)

        let items = try space.fetchItems()
        XCTAssertEqual(items.count, 3)
    }
}
