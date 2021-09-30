import XCTest
import Combine
import CoreData
import Apollo

@testable import Sync


class FetchListTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var events: SyncEvents!
    var queue: OperationQueue!
    var lastRefresh: MockLastRefresh!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        events = PassthroughSubject()
        queue = OperationQueue()
        lastRefresh = MockLastRefresh()
        space = Space(container: .testContainer)
    }

    override func tearDownWithError() throws {
        cancellables = []
        try space.clear()
    }

    func performOperation(
        token: String = "test-token",
        apollo: ApolloClientProtocol? = nil,
        space: Space? = nil,
        events: SyncEvents? = nil,
        maxItems: Int = 400,
        lastRefresh: LastRefresh? = nil
    ) {
        let operation = FetchList(
            token: token,
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            events: events ?? self.events,
            maxItems: maxItems,
            lastRefresh: lastRefresh ?? self.lastRefresh
        )

        let expectationToCompleteOperation = expectation(
            description: "Expect the FetchList operation to complete"
        )

        operation.completionBlock = {
            expectationToCompleteOperation.fulfill()
        }

        queue.addOperation(operation)

        wait(for: [expectationToCompleteOperation], timeout: 1)
    }

    func test_refresh_fetchesUserByTokenQueryWithGivenToken() {
        apollo.stubFetch(toReturnFixturedNamed: "list", asResultType: UserByTokenQuery.self)

        performOperation()

        XCTAssertFalse(apollo.fetchCalls.isEmpty)
        let call: MockApolloClient.FetchCall<UserByTokenQuery> = apollo.fetchCall(at: 0)
        XCTAssertEqual(call.query.token, "test-token")

        XCTAssertEqual(lastRefresh.refreshedCallCount, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() throws {
        apollo.stubFetch(toReturnFixturedNamed: "list", asResultType: UserByTokenQuery.self)

        performOperation()

        let savedItems = try space.fetchAllSavedItems()
        XCTAssertEqual(savedItems.count, 2)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.remoteID, "saved-item-1")
        XCTAssertEqual(savedItem.url, URL(string: "https://example.com/item-1")!)
        XCTAssertEqual(savedItem.createdAt?.timeIntervalSince1970, 0)
        XCTAssertEqual(savedItem.deletedAt?.timeIntervalSince1970, 1)
        XCTAssertEqual(savedItem.isArchived, false)
        XCTAssertTrue(savedItem.isFavorite)

        let item = savedItem.item
        XCTAssertEqual(item?.remoteID, "item-1")
        XCTAssertEqual(item?.givenURL, URL(string: "https://given.example.com/item-1")!)
        XCTAssertEqual(item?.resolvedURL, URL(string: "https://resolved.example.com/item-1")!)
        XCTAssertEqual(item?.title, "Item 1")
        XCTAssertEqual(item?.topImageURL, URL(string: "https://example.com/item-1/top-image.jpg")!)
        XCTAssertEqual(item?.domain, "example.com")
        XCTAssertEqual(item?.language, "en")
        XCTAssertEqual(item?.timeToRead, 6)
        XCTAssertEqual(item?.particleJSON, "<just-json-things>")
        XCTAssertEqual(item?.excerpt, "Cursus Aenean Elit")

        let domain = item?.domainMetadata
        XCTAssertEqual(domain?.name, "WIRED")
        XCTAssertEqual(domain?.logo, URL(string: "http://example.com/item-1/domain-logo.jpg")!)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsDuplicateItems_createsSingleItem() throws {
        apollo.stubFetch(toReturnFixturedNamed: "duplicate-list", asResultType: UserByTokenQuery.self)

        performOperation()

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistingItems() throws {
        apollo.stubFetch(toReturnFixturedNamed: "updated-item", asResultType: UserByTokenQuery.self)
        try space.seedItem(remoteID: "saved-item-1", title: "Item 1")

        performOperation()

        let item = try space.fetchSavedItem(byRemoteID: "saved-item-1")
        XCTAssertEqual(item?.item?.title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() throws {
        apollo.stubFetch(ofQueryType: UserByTokenQuery.self, toReturnError: TestError.anError)

        var error: Error?
        events.sink { event in
            guard case .error(let actualError) = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }
            error = actualError
        }.store(in: &cancellables)

        performOperation()

        XCTAssertEqual(error as? TestError, .anError)
        XCTAssertEqual(lastRefresh.refreshedCallCount, 0)
    }

    func test_refresh_whenResponseIncludesMultiplePages_fetchesNextPage() throws {
        var fetches = 0
        apollo.stubFetch { (query: UserByTokenQuery, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

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

            queue.async {
                completion?(.success(result.asGraphQLResult(from: query)))
            }
            return MockCancellable()
        }

        performOperation()

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 2)
    }

    func test_refresh_whenItemCountExceedsMax_fetchesMaxNumberOfItems() throws {
        var fetches = 0
        apollo.stubFetch { (query: UserByTokenQuery, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

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

            queue.async {
                completion?(.success(result.asGraphQLResult(from: query)))
            }

            return MockCancellable()
        }

        performOperation(maxItems: 3)

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 3)
    }

    func test_refresh_whenUpdatedSinceIsPresent_includesUpdatedSinceFilter() {
        lastRefresh.stubGetLastRefresh { 123456789 }
        apollo.stubFetch(toReturnFixturedNamed: "list", asResultType: UserByTokenQuery.self)

        performOperation()

        let call: MockApolloClient.FetchCall<UserByTokenQuery> = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call.query.savedItemsFilter)
        XCTAssertEqual(call.query.savedItemsFilter?.updatedSince, 123456789)
    }

    func test_refresh_whenUpdatedSinceIsNotPresent_onlyFetchesUnreadItems() {
        apollo.stubFetch(toReturnFixturedNamed: "list", asResultType: UserByTokenQuery.self)

        performOperation()

        let call: MockApolloClient.FetchCall<UserByTokenQuery> = apollo.fetchCall(at: 0)
        XCTAssertEqual(call.query.savedItemsFilter?.status, .unread)
    }

    func test_refresh_whenResultsAreEmpty_finishesOperationSuccessfully() {
        apollo.stubFetch(
            toReturnFixturedNamed: "empty-list",
            asResultType: UserByTokenQuery.self
        )

        performOperation()
        XCTAssertEqual(lastRefresh.refreshedCallCount, 1)
    }
}
