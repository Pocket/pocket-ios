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

    func subject(
        token: String = "test-token",
        apollo: ApolloClientProtocol? = nil,
        space: Space? = nil,
        events: SyncEvents? = nil,
        maxItems: Int = 400,
        lastRefresh: LastRefresh? = nil
    ) -> FetchList {
        FetchList(
            token: token,
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            events: events ?? self.events,
            maxItems: maxItems,
            lastRefresh: lastRefresh ?? self.lastRefresh
        )
    }

    func test_refresh_fetchesUserByTokenQueryWithGivenToken() async {
        let fixture = Fixture.load(name: "list")
            .replacing("MARTICLE", withFixtureNamed: "marticle")
        apollo.stubFetch(toReturnFixture: fixture, asResultType: UserByTokenQuery.self)

        let service = subject()
        _ = await service.execute()

        XCTAssertFalse(apollo.fetchCalls.isEmpty)
        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.token, "test-token")

        XCTAssertEqual(lastRefresh.refreshedCallCount, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() async throws {
        let fixture = Fixture.load(name: "list")
            .replacing("MARTICLE", withFixtureNamed: "marticle")
        apollo.stubFetch(toReturnFixture: fixture, asResultType: UserByTokenQuery.self)

        let service = subject()
        _ = await service.execute()

        let savedItems = try space.fetchAllSavedItems()
        XCTAssertEqual(savedItems.count, 2)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.cursor, "cursor-1")
        XCTAssertEqual(savedItem.remoteID, "saved-item-1")
        XCTAssertEqual(savedItem.url, URL(string: "https://example.com/item-1")!)
        XCTAssertEqual(savedItem.createdAt?.timeIntervalSince1970, 0)
        XCTAssertEqual(savedItem.deletedAt?.timeIntervalSince1970, nil)
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
        XCTAssertEqual(item?.excerpt, "Cursus Aenean Elit")
        XCTAssertEqual(item?.datePublished, Date(timeIntervalSinceReferenceDate: 631195261))

        let expected: [ArticleComponent] = Fixture.load(name: "marticle").decode()
        XCTAssertEqual(item?.article?.components, expected)

        let authors = item?.authors?.compactMap { $0 as? Author }
        XCTAssertEqual(authors?[0].id, "author-1")
        XCTAssertEqual(authors?[0].name, "Eleanor")
        XCTAssertEqual(authors?[0].url, URL(string: "https://example.com/authors/eleanor")!)

        let domain = item?.domainMetadata
        XCTAssertEqual(domain?.name, "WIRED")
        XCTAssertEqual(domain?.logo, URL(string: "http://example.com/item-1/domain-logo.jpg")!)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsDuplicateItems_createsSingleItem() async throws {
        apollo.stubFetch(toReturnFixturedNamed: "duplicate-list", asResultType: UserByTokenQuery.self)

        let service = subject()
        _ = await service.execute()

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistingItems() async throws {
        apollo.stubFetch(toReturnFixturedNamed: "updated-item", asResultType: UserByTokenQuery.self)
        try space.seedSavedItem(
            remoteID: "saved-item-1",
            item: space.buildItem(title: "Item 1")
        )

        let service = subject()
        _ = await service.execute()

        let item = try space.fetchSavedItem(byRemoteID: "saved-item-1")
        XCTAssertEqual(item?.item?.title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() async throws {
        apollo.stubFetch(ofQueryType: UserByTokenQuery.self, toReturnError: TestError.anError)

        var error: Error?
        events.sink { event in
            guard case .error(let actualError) = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }
            error = actualError
        }.store(in: &cancellables)

        let service = subject()
        _ = await service.execute()

        XCTAssertEqual(error as? TestError, .anError)
        XCTAssertEqual(lastRefresh.refreshedCallCount, 0)
    }

    func test_refresh_whenResponseIncludesMultiplePages_fetchesNextPage() async throws {
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

        let service = subject()
        _ = await service.execute()

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 2)
    }

    func test_refresh_whenItemCountExceedsMax_fetchesMaxNumberOfItems() async throws {
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

        let service = subject(maxItems: 3)
        _ = await service.execute()

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 3)
    }

    func test_refresh_whenUpdatedSinceIsPresent_includesUpdatedSinceFilter() async {
        lastRefresh.stubGetLastRefresh { 123456789 }

        let fixture = Fixture.load(name: "list")
            .replacing("MARTICLE", withFixtureNamed: "marticle")
        apollo.stubFetch(toReturnFixture: fixture, asResultType: UserByTokenQuery.self)

        let service = subject()
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call?.query.savedItemsFilter)
        XCTAssertEqual(call?.query.savedItemsFilter?.updatedSince, 123456789)
    }

    func test_refresh_whenUpdatedSinceIsNotPresent_onlyFetchesUnreadItems() async {
        let fixture = Fixture.load(name: "list")
            .replacing("MARTICLE", withFixtureNamed: "marticle")
        apollo.stubFetch(toReturnFixture: fixture, asResultType: UserByTokenQuery.self)

        let service = subject()
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.savedItemsFilter?.status, .unread)
    }

    func test_refresh_whenResultsAreEmpty_finishesOperationSuccessfully() async {
        apollo.stubFetch(
            toReturnFixturedNamed: "empty-list",
            asResultType: UserByTokenQuery.self
        )

        let service = subject()
        _ = await service.execute()

        XCTAssertEqual(lastRefresh.refreshedCallCount, 1)
    }

    func test_execute_whenClientSideNetworkFails_retries() async {
        let initialError = URLSessionClient.URLSessionClientError.networkError(
            data: Data(),
            response: nil,
            underlying: TestError.anError
        )

        apollo.stubFetch(ofQueryType: UserByTokenQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }

    func test_execute_whenResponseIs5XX_retries() async {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        apollo.stubFetch(ofQueryType: UserByTokenQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }
}
