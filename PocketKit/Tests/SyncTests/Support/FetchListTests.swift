import XCTest
import Combine
import CoreData
import Apollo
import PocketGraph

@testable import Sync

class FetchListTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var events: SyncEvents!
    var initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>!
    var queue: OperationQueue!
    var lastRefresh: MockLastRefresh!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        events = PassthroughSubject()
        initialDownloadState = .init(.unknown)
        queue = OperationQueue()
        lastRefresh = MockLastRefresh()
        space = .testSpace()
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
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>? = nil,
        maxItems: Int = 400,
        lastRefresh: LastRefresh? = nil
    ) -> FetchList {
        FetchList(
            token: token,
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            events: events ?? self.events,
            initialDownloadState: initialDownloadState ?? self.initialDownloadState,
            maxItems: maxItems,
            lastRefresh: lastRefresh ?? self.lastRefresh
        )
    }

    func test_refresh_fetchesFetchSavesQueryWithGivenToken() async {
        apollo.setupSyncResponse()

        let service = subject()
        _ = await service.execute()

        XCTAssertFalse(apollo.fetchCalls(withQueryType: FetchSavesQuery.self).isEmpty)
        let call: MockApolloClient.FetchCall<FetchSavesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.token, "test-token")

        XCTAssertEqual(lastRefresh.refreshedCallCount, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() async throws {
        apollo.setupSyncResponse()

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

        let tags = savedItem.tags?.compactMap { $0 as? Tag }
        XCTAssertEqual(tags?.count, 2)
        XCTAssertEqual(tags?[0].name, "tag-1")

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

        let images = item?.images?.compactMap { $0 as? Image } ?? []
        XCTAssertEqual(images[0].source, URL(string: "http://example.com/item-1/image-1.jpg"))

        XCTAssertEqual(item?.syndicatedArticle?.itemID, "syndicated-article-item-id")
    }

    func test_refresh_whenFetchSucceeds_andResultContainsDuplicateItems_createsSingleItem() async throws {
        apollo.setupSyncResponse(listFixtureName: "duplicate-list")

        let service = subject()
        _ = await service.execute()

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistingItems() async throws {
        apollo.setupSyncResponse(listFixtureName: "updated-item")
        try space.createSavedItem(
            remoteID: "saved-item-1",
            item: space.buildItem(title: "Item 1")
        )

        let service = subject()
        _ = await service.execute()

        let item = try space.fetchSavedItem(byRemoteID: "saved-item-1")
        XCTAssertEqual(item?.item?.title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() async throws {
        apollo.setupTagsResponse()
        apollo.stubFetch(ofQueryType: FetchSavesQuery.self, toReturnError: TestError.anError)

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
        apollo.setupTagsResponse()
        apollo.stubFetch { (query: FetchSavesQuery, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

            let result: Fixture
            switch fetches {
            case 0:
                result = Fixture.load(name: "paginated-list-1")
            case 1:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-1")
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
        apollo.setupTagsResponse()
        apollo.stubFetch { (query: FetchSavesQuery, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

            let result: Fixture
            switch fetches {
            case 0:
                XCTAssertEqual(query.pagination.unwrapped?.first, 3)

                result = Fixture.load(name: "large-list-1")
            case 1:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-1")
                XCTAssertEqual(query.pagination.unwrapped?.first.unwrapped, 2)

                result = Fixture.load(name: "large-list-2")
            case 2:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-2")
                XCTAssertEqual(query.pagination.unwrapped?.first.unwrapped, 1)

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
        apollo.setupSyncResponse()

        let service = subject()
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<FetchSavesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call?.query.savedItemsFilter)
        XCTAssertEqual(call?.query.savedItemsFilter.unwrapped?.updatedSince, 123456789)
    }

    func test_refresh_whenUpdatedSinceIsPresent_doesNotSendInitialDownloadFetchedFirstPageEvent() async {
        initialDownloadState.send(.completed)
        apollo.setupSyncResponse()

        let receivedEvent = expectation(description: "receivedEvent")
        receivedEvent.isInverted = true
        initialDownloadState.sink { state in
            switch state {
            case .unknown, .completed, .started:
                break
            case .paginating:
                XCTFail("Should not change state to paginating if initial download has completed")
                receivedEvent.fulfill()
            }
        }.store(in: &cancellables)

        let service = subject()
        _ = await service.execute()

        wait(for: [receivedEvent], timeout: 1)
    }

    func test_refresh_whenUpdatedSinceIsNotPresent_onlyFetchesUnreadItems() async {
        apollo.setupSyncResponse()

        let service = subject()
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<FetchSavesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.savedItemsFilter.unwrapped?.status.value, .unread)
    }

    func test_execute_whenUpdatedSinceIsNotPresent_downloadsAllTags() async throws {
        apollo.setupFetchListResponse(fixtureName: "empty-list")

        var tagsPageCount = 1
        apollo.stubFetch { (query: TagsQuery, _, _, queue, completion) in
            defer { tagsPageCount += 1 }

            guard tagsPageCount < 3 else {
                XCTFail("Received unexpected number of requests for tags: \(tagsPageCount)")
                return MockCancellable()
            }

            let fixture = Fixture.load(name: "tags-page-\(tagsPageCount)")
            let result = fixture.asGraphQLResult(from: query)
            queue.async {
                completion?(.success(result))
            }

            return MockCancellable()
        }

        let operation = subject()
        _ = await operation.execute()

        let fetchCall1 = apollo.fetchCall(withQueryType: TagsQuery.self, at: 0)
        XCTAssertNotNil(fetchCall1)
        XCTAssertEqual(fetchCall1?.query.pagination.unwrapped?.after.unwrapped, nil)

        let fetchCall2 = apollo.fetchCall(withQueryType: TagsQuery.self, at: 1)
        XCTAssertEqual(fetchCall2?.query.pagination.unwrapped?.after.unwrapped, "tag-2-cursor")

        let tags = try space.context.fetch(Tag.fetchRequest())
        XCTAssertEqual(tags.count, 4)
        XCTAssertFalse(space.context.hasChanges)
    }

    func test_refresh_whenIsInitialDownload_sendsAppropriateEvents() async {
        initialDownloadState.send(.started)
        apollo.setupSyncResponse()

        let receivedFirstPageEvent = expectation(description: "receivedFirstPageEvent")
        let receivedCompletedEvent = expectation(description: "receivedCompletedEvent")
        initialDownloadState.sink { state in
            switch state {
            case .unknown, .started:
                break
            case .paginating(let totalCount):
                XCTAssertEqual(2, totalCount)
                receivedFirstPageEvent.fulfill()
            case .completed:
                receivedCompletedEvent.fulfill()
            }
        }.store(in: &cancellables)

        let service = subject()
        _ = await service.execute()

        wait(for: [receivedFirstPageEvent, receivedCompletedEvent], timeout: 1)
    }

    func test_refresh_whenResultsAreEmpty_finishesOperationSuccessfully() async {
        apollo.setupSyncResponse(listFixtureName: "empty-list")

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

        apollo.setupTagsResponse()
        apollo.stubFetch(ofQueryType: FetchSavesQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }

    func test_execute_whenResponseIs5XX_retries() async {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        apollo.setupTagsResponse()
        apollo.stubFetch(ofQueryType: FetchSavesQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }
}

extension MockApolloClient {
    func setupFetchListResponse(fixtureName: String = "list") {
        stubFetch(
            toReturnFixture: .load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle"),
            asResultType: FetchSavesQuery.self
        )
    }

    func setupTagsResponse(fixtureName: String = "empty-tags") {
        stubFetch(
            toReturnFixture: .load(name: "empty-tags"),
            asResultType: TagsQuery.self
        )
    }

    func setupSyncResponse(
        listFixtureName: String = "list",
        tagsFixtureName: String = "empty-tags"
    ) {
        setupFetchListResponse(fixtureName: listFixtureName)
        setupTagsResponse(fixtureName: tagsFixtureName)
    }
}
