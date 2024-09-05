// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import CoreData
import Apollo
import PocketGraph
import SharedPocketKit
import Foundation

@testable import Sync

class FetchSavesTests: XCTestCase {
    var apollo: MockApolloClient!
    var user: MockUser!
    var space: Space!
    var events: SyncEvents!
    var initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>!
    var queue: OperationQueue!
    var lastRefresh: MockLastRefresh!
    var cancellables: Set<AnyCancellable> = []
    var task: PersistentSyncTask!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apollo = MockApolloClient()
        user = MockUser()
        events = PassthroughSubject()
        initialDownloadState = .init(.unknown)
        queue = OperationQueue()
        lastRefresh = MockLastRefresh()
        space = .testSpace()
        task = PersistentSyncTask(context: space.backgroundContext)
        task.syncTaskContainer = SyncTaskContainer(task: .fetchSaves)
        try space.save()
    }

    override func tearDownWithError() throws {
        cancellables = []
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        apollo: ApolloClientProtocol? = nil,
        space: Space? = nil,
        events: SyncEvents? = nil,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>? = nil,
        lastRefresh: LastRefresh? = nil
    ) -> FetchSaves {
        FetchSaves(
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            events: events ?? self.events,
            initialDownloadState: initialDownloadState ?? self.initialDownloadState,
            lastRefresh: lastRefresh ?? self.lastRefresh
        )
    }

    func tagsSubject(
        apollo: ApolloClientProtocol? = nil,
        space: Space? = nil,
        events: SyncEvents? = nil,
        lastRefresh: LastRefresh? = nil
    ) -> FetchTags {
        FetchTags(
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            events: events ?? self.events,
            lastRefresh: lastRefresh ?? self.lastRefresh
        )
    }

    func test_refresh_fetchesFetchSavesQueryWithGivenToken() async {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse()

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        XCTAssertFalse(apollo.fetchCalls(withQueryType: FetchSavesQuery.self).isEmpty)
        let _: MockApolloClient.FetchCall<FetchSavesQuery>? = apollo.fetchCall(at: 0)

        XCTAssertEqual(lastRefresh.refreshedSavesCallCount, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() async throws {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse()

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        let savedItems = try space.fetchAllSavedItems()
        XCTAssertEqual(savedItems.count, 2)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.cursor, "cursor-1")
        XCTAssertEqual(savedItem.remoteID, "saved-item-1")
        XCTAssertEqual(savedItem.url, "https://example.com/item-1")
        XCTAssertEqual(savedItem.createdAt.timeIntervalSince1970, 0)
        XCTAssertEqual(savedItem.deletedAt?.timeIntervalSince1970, nil)
        XCTAssertEqual(savedItem.isArchived, false)
        XCTAssertTrue(savedItem.isFavorite)

        let tags = savedItem.tags?.compactMap { $0 as? Tag }
        XCTAssertEqual(tags?.count, 2)
        XCTAssertEqual(tags?[0].name, "tag-1")

        let item = savedItem.item
        XCTAssertEqual(item?.remoteID, "item-1")
        XCTAssertEqual(item?.givenURL, "https://given.example.com/item-1")
        XCTAssertEqual(item?.resolvedURL, "https://resolved.example.com/item-1")
        XCTAssertEqual(item?.title, "Item 1")
        XCTAssertEqual(item?.topImageURL, URL(string: "https://example.com/item-1/top-image.jpg")!)
        XCTAssertEqual(item?.domain, "example.com")
        XCTAssertEqual(item?.language, "en")
        XCTAssertEqual(item?.timeToRead, 6)
        XCTAssertEqual(item?.excerpt, "Cursus Aenean Elit")
        XCTAssertEqual(item?.datePublished, Date(timeIntervalSinceReferenceDate: 631195261))

        let expected: [ArticleComponent] = Fixture.load(name: "marticle").decode()
        XCTAssertEqual(item?.article?.components, expected)

        let authors = item?.authors?.compactMap { $0 as? CDAuthor }
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

    func test_refresh_whenFetchSucceeds_useCorpusItemPublisherIfItExists() async throws {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse(listFixtureName: "list-with-corpusItem")

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        let savedItems = try space.fetchAllSavedItems().sorted { $0.remoteID! < $1.remoteID! }
        XCTAssertEqual(savedItems.count, 2)

        let savedItem1 = savedItems[0]
        let item1 = savedItem1.item
        XCTAssertEqual(savedItem1.remoteID, "saved-item-1")
        XCTAssertEqual(item1?.domain, "CorpusItemPublisher-1")

        let savedItem2 = savedItems[1]
        let item2 = savedItem2.item
        XCTAssertEqual(item2!.domain!, "example.com")
    }

    func test_refresh_whenFetchSucceeds_andResultContainsDuplicateItems_createsSingleItem() async throws {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse(listFixtureName: "duplicate-list")

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistingItems() async throws {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse(listFixtureName: "updated-item")
        try space.createSavedItem(
            remoteID: "saved-item-1",
            url: "http://example.com/item-1",
            item: space.buildItem(title: "Item 1")
        )

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        let item = try space.fetchSavedItem(byURL: "http://example.com/item-1")
        XCTAssertEqual(item?.item?.title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() async throws {
        user.stubSetStatus { _ in }
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
        _ = await service.execute(syncTaskId: task.objectID)

        XCTAssertEqual(error as? TestError, .anError)
        XCTAssertEqual(lastRefresh.refreshedSavesCallCount, 0)
    }

    func test_refresh_whenResponseIncludesMultiplePages_fetchesNextPage() async throws {
        var fetches = 0
        user.stubSetStatus { _ in }
        apollo.setupTagsResponse()
        apollo.stubFetch { [weak self] (query: FetchSavesQuery, _, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

            let result: Fixture
            switch fetches {
            case 0:
                result = Fixture.load(name: "paginated-list-1")
            case 1:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-1")
                XCTAssertEqual(self?.task.currentCursor!, "cursor-1")
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
        XCTAssertNil(self.task.currentCursor, "cursor-1")
        _ = await service.execute(syncTaskId: task.objectID)

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 2)
    }

    func test_refresh_whenItemCountExceedsMax_fetchesMaxNumberOfItems() async throws {
        var fetches = 0
        let pages = Int(ceil(Double((SyncConstants.Saves.firstLoadMaxCount - SyncConstants.Saves.initalPageSize) / SyncConstants.Saves.pageSize))) + 2
        print(pages)

        user.stubSetStatus { _ in }
        apollo.setupTagsResponse()
        apollo.stubFetch { [weak self] (query: FetchSavesQuery, _, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

            let result: Fixture
            switch fetches {
            case 0:
                XCTAssertEqual(query.pagination.unwrapped?.first, 15)
                XCTAssertNil(self?.task.currentCursor)

                result = Fixture.load(name: "large-list-1")
            case 1:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-1")
                XCTAssertEqual(query.pagination.unwrapped?.first.unwrapped, 30)
                // check that the last cursor was persisted before we return, since we dont have a way to hook into after each save operation.
                XCTAssertEqual(self?.task.currentCursor!, "cursor-1")

                result = Fixture.load(name: "large-list-2")
            case 2:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-2")
                XCTAssertEqual(query.pagination.unwrapped?.first.unwrapped, 30)
                // check that the last cursor was persisted before we return, since we dont have a way to hook into after each save operation.
                XCTAssertEqual(self?.task.currentCursor!, "cursor-2")

                result = Fixture.load(name: "large-list-3")
            case 3...pages:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-3")
                XCTAssertEqual(query.pagination.unwrapped?.first.unwrapped, 30)
                // check that the last cursor was persisted before we return, since we dont have a way to hook into after each save operation.
                XCTAssertEqual(self?.task.currentCursor!, "cursor-3")

                result = Fixture.load(name: "large-list-3")
            default:
                XCTFail("Unexpected number of fetches: \(fetches)")
                return MockCancellable()
            }

            completion?(.success(result.asGraphQLResult(from: query)))

            return MockCancellable()
        }

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)
        XCTAssertEqual(fetches, pages)
    }

    func test_refresh_whenSyncTaskHasACursor_taskResumesFromCursor() async throws {
        task.currentCursor = "cursor-1"
        try space.save()

        var fetches = 0
        user.stubSetStatus { _ in }
        apollo.setupTagsResponse()
        apollo.stubFetch { [weak self] (query: FetchSavesQuery, _, _, _, queue, completion) -> Apollo.Cancellable in
            defer { fetches += 1 }

            let result: Fixture
            switch fetches {
            case 0:
                XCTAssertEqual(query.pagination.unwrapped?.after.unwrapped, "cursor-1")
                XCTAssertEqual(self?.task.currentCursor!, "cursor-1")
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
        _ = await service.execute(syncTaskId: task.objectID)
        XCTAssertEqual(task.currentCursor!, "cursor-2")

        let items = try space.fetchSavedItems()
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenUpdatedSinceIsPresent_includesUpdatedSinceFilter() async {
        user.stubSetStatus { _ in }
        lastRefresh.stubGetLastRefreshSaves { 123456789 }
        apollo.setupFetchSavesSyncResponse()

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        let call: MockApolloClient.FetchCall<FetchSavesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call?.query.savedItemsFilter)
        XCTAssertEqual(call?.query.savedItemsFilter.unwrapped?.updatedSince, 123456789)
    }

    func test_refresh_whenUpdatedSinceIsPresent_doesNotSendInitialDownloadFetchedFirstPageEvent() async {
        user.stubSetStatus { _ in }
        initialDownloadState.send(.completed)
        apollo.setupFetchSavesSyncResponse()
        lastRefresh.stubGetLastRefreshSaves {
            return Date().timeIntervalSince1970
        }

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
        _ = await service.execute(syncTaskId: task.objectID)

        await fulfillment(of: [receivedEvent], timeout: 1)
    }

    func test_refresh_whenUpdatedSinceIsNotPresent_onlyFetchesUnreadItems() async {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse()

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        let call: MockApolloClient.FetchCall<FetchSavesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.savedItemsFilter.unwrapped?.status.value, .unread)
    }

    func test_execute_whenUpdatedSinceIsNotPresent_downloadsAllTags() async throws {
        user.stubSetStatus { _ in }

        var tagsPageCount = 1
        apollo.stubFetch { (query: TagsQuery, _, _, _, queue, completion) in
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

        let operation = tagsSubject()
        _ = await operation.execute(syncTaskId: task.objectID)

        let fetchCall1 = apollo.fetchCall(withQueryType: TagsQuery.self, at: 0)
        XCTAssertNotNil(fetchCall1)
        XCTAssertEqual(fetchCall1?.query.pagination.unwrapped?.after.unwrapped, nil)

        let fetchCall2 = apollo.fetchCall(withQueryType: TagsQuery.self, at: 1)
        XCTAssertEqual(fetchCall2?.query.pagination.unwrapped?.after.unwrapped, "tag-2-cursor")

        let tags = try space.backgroundContext.fetch(Tag.fetchRequest())
        XCTAssertEqual(tags.count, 4)
        XCTAssertFalse(space.backgroundContext.hasChanges)
    }

    func test_refresh_whenIsInitialDownload_sendsAppropriateEvents() async {
        user.stubSetStatus { _ in }
        initialDownloadState.send(.started)
        apollo.setupFetchSavesSyncResponse()

        let receivedFirstPageEvent = expectation(description: "receivedFirstPageEvent")
        let receivedCompletedEvent = expectation(description: "receivedCompletedEvent")
        initialDownloadState.sink { state in
            switch state {
            case .unknown, .started:
                break
            case .paginating(let totalCount, _):
                XCTAssertEqual(2, totalCount)
                receivedFirstPageEvent.fulfill()
            case .completed:
                receivedCompletedEvent.fulfill()
            }
        }.store(in: &cancellables)

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        await fulfillment(of: [receivedFirstPageEvent, receivedCompletedEvent], timeout: 2)
    }

    func test_refresh_whenResultsAreEmpty_finishesOperationSuccessfully() async {
        user.stubSetStatus { _ in }
        apollo.setupFetchSavesSyncResponse(listFixtureName: "empty-list")

        let service = subject()
        _ = await service.execute(syncTaskId: task.objectID)

        XCTAssertEqual(lastRefresh.refreshedSavesCallCount, 1)
    }

    func test_execute_whenClientSideNetworkFails_retries() async {
        let initialError = URLSessionClient.URLSessionClientError.networkError(
            data: Data(),
            response: nil,
            underlying: TestError.anError
        )
        user.stubSetStatus { _ in }
        apollo.setupTagsResponse()
        apollo.stubFetch(ofQueryType: FetchSavesQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }

    func test_execute_whenResponseIs5XX_does_not_retry() async {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        user.stubSetStatus { _ in }
        apollo.setupTagsResponse()
        apollo.stubFetch(ofQueryType: FetchSavesQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .failure = result else {
            XCTFail("Expected failure result but got \(result)")
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

    func setupFetchSavesSyncResponse(
        listFixtureName: String = "list",
        tagsFixtureName: String = "empty-tags"
    ) {
        setupFetchListResponse(fixtureName: listFixtureName)
        setupTagsResponse(fixtureName: tagsFixtureName)
    }
}
