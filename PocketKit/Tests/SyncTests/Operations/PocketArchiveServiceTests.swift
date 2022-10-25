import XCTest
import Apollo
import ApolloAPI
import Foundation
import Combine
import PocketGraph

@testable import Sync

@MainActor
class PocketArchiveServiceTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var queue: OperationQueue!
    var subscriptions: [AnyCancellable] = []

    override func setUp() {
        apollo = MockApolloClient()
        space = .testSpace()
        queue = OperationQueue()

        setupArchivePagination()
    }

    override func tearDownWithError() throws {
        try space.clear()
        subscriptions = []
    }

    func subject(
        apollo: MockApolloClient? = nil,
        space: Space? = nil
    ) -> PocketArchiveService {
        PocketArchiveService(
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            pageSize: 2
        )
    }

    func test_applySortingOnArchivedItems() throws {
        let service = subject()
        service.selectedSortOption = .ascending

        let itemsChanged = expectation(description: "itemsChanged")
        service.results.dropFirst().sink { items in
            itemsChanged.fulfill()
        }.store(in: &subscriptions)

        service.fetch()

        wait(for: [itemsChanged], timeout: 1)

        let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.query.sort.unwrapped?.sortOrder.value, .asc)
    }

    func test_fetch_executesAQuery() {
        let service = subject()

        let itemsChanged = expectation(description: "itemsChanged")
        service.results.dropFirst().sink { items in
            XCTAssertEqual(items.count, 5)
            itemsChanged.fulfill()
        }.store(in: &subscriptions)

        service.fetch()

        wait(for: [itemsChanged], timeout: 1)

        let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.query.filter.unwrapped?.isArchived, true)
        XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, nil)
        XCTAssertEqual(call?.query.pagination.unwrapped?.first.unwrapped, 2)
    }

    func test_theOperation_whenQuerySucceeds_storesResultsInCoreData() throws {
        let service = subject()
        let initialLoad = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            initialLoad.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        wait(for: [initialLoad], timeout: 1)

        let archivedItems = try space.fetchArchivedItems()
        XCTAssertEqual(archivedItems.count, 2)

        do {
            let archivedItem = archivedItems[0]
            XCTAssertEqual(archivedItem.remoteID, "archived-saved-item-2")
            XCTAssertEqual(archivedItem.archivedAt, Date(timeIntervalSince1970: 5))
            XCTAssertEqual(archivedItem.item?.syndicatedArticle?.itemID, "archived-syndicated-article-id")
        }

        do {
            let archivedItem = archivedItems[1]
            XCTAssertEqual(archivedItem.remoteID, "archived-saved-item-1")
        }
    }

    func test_observingCoreDataChanges_whenItemIsAdded_InsertsNewItemIntoResults() throws {
        let service = subject()
        service.selectedSortOption = .ascending

        let initialLoad = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            initialLoad.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        wait(for: [initialLoad], timeout: 1)

        let itemAdded = expectation(description: "itemAdded")
        service.results.dropFirst().sink { items in
            XCTAssertEqual(items.count, 6)

            if case .loaded(let item) = items[0] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-3")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            if case .loaded(let item) = items[1] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-2")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            if case .loaded(let item) = items[2] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-1")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            XCTAssertEqual(items[3], .notLoaded)
            XCTAssertEqual(items[4], .notLoaded)
            XCTAssertEqual(items[5], .notLoaded)

            itemAdded.fulfill()
        }.store(in: &subscriptions)

        try space.createSavedItem(
            remoteID: "archived-saved-item-3",
            isArchived: true,
            archivedAt: Date()
        )
        wait(for: [itemAdded], timeout: 1)

    }

    func test_observingCoreDataChanges_whenItemIsUnarchived_RemovesItemFromResults() throws {
        let service = subject()

        let initialLoad = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            initialLoad.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        wait(for: [initialLoad], timeout: 1)

        let itemRemoved = expectation(description: "itemRemoved")
        service.results.dropFirst().sink { items in
            XCTAssertEqual(items.count, 4)
            if case .loaded(let item) = items[0] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-1")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            XCTAssertEqual(items[1], .notLoaded)
            XCTAssertEqual(items[2], .notLoaded)
            XCTAssertEqual(items[3], .notLoaded)

            itemRemoved.fulfill()
        }.store(in: &subscriptions)

        let archivedItem = try space.fetchSavedItem(byRemoteID: "archived-saved-item-2")
        XCTAssertNotNil(archivedItem)
        archivedItem?.isArchived = false
        archivedItem?.deletedAt = nil
        try space.save()

        wait(for: [itemRemoved], timeout: 1)
    }

    func test_fetch_whenFetchingASubsequentPage_works() throws {
        // setup service
        let service = subject()

        // fetch the initial page
        let loadFirstPage = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            loadFirstPage.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        wait(for: [loadFirstPage], timeout: 1)

        // stub apollo to respond with next page
        apollo.stubFetch(
            toReturnFixtureNamed: "archived-items-page-2",
            asResultType: SavedItemSummariesQuery.self
        )

        // fetch the next page
        let loadSecondPage = expectation(description: "loadSecondPage")
        service.results.dropFirst().first().sink { items in
            // assert that results reflect content from both pages
            if case .loaded(let item) = items[0] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-2")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            if case .loaded(let item) = items[1] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-1")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            if case .loaded(let item) = items[2] {
                XCTAssertEqual(item.remoteID, "archived-saved-item-0")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            if case .loaded(let item) = items[3] {
                XCTAssertEqual(item.remoteID, "archived-saved-item--1")
            } else {
                XCTFail("Expected loaded item but got notLoaded")
            }

            XCTAssertEqual(items[4], .notLoaded)
            loadSecondPage.fulfill()
        }.store(in: &subscriptions)
        service.fetch(at: [2, 3])
        wait(for: [loadSecondPage], timeout: 1)

        // assert that pagination params are correct
        let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 1)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.query.filter.unwrapped?.isArchived.unwrapped, true)
        XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, "cursor-2")
        XCTAssertEqual(call?.query.pagination.unwrapped?.first.unwrapped, 2)
    }

    func test_fetch_whenFetchingIndexMultipleContiguousPagesAhead_fetchesEachIntermediatePage() throws {
        // setup service
        let service = subject()

        // fetch the initial page
        let initialLoad = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            initialLoad.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        wait(for: [initialLoad], timeout: 1)
        let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, nil)

        // fetch the second and third pages
        let loadThirdPage = expectation(description: "loadThirdPage")
        service.results.dropFirst(2).first().sink { items in
            loadThirdPage.fulfill()
        }.store(in: &subscriptions)

        service.fetch(at: [3, 4])
        wait(for: [loadThirdPage], timeout: 1)

        do {
            // assert that pagination params are correct
            let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 1)
            XCTAssertEqual(call?.query.filter.unwrapped?.isArchived.unwrapped, true)
            XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, "cursor-2")
        }

        do {
            let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 2)
            XCTAssertNotNil(call)
            XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, "cursor-4")
        }
    }

    func test_fetch_whenFetchingIndexMultipleNonContiguousPagesAhead_fetchesEachIntermediatePage() throws {
        // setup service
        let service = subject()

        // fetch the initial page
        let initialLoad = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            initialLoad.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        wait(for: [initialLoad], timeout: 1)
        let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, nil)

        // fetch the second and third pages
        let loadThirdPage = expectation(description: "loadThirdPage")
        service.results.dropFirst(2).first().sink { items in
            loadThirdPage.fulfill()
        }.store(in: &subscriptions)

        service.fetch(at: [4])
        wait(for: [loadThirdPage], timeout: 1)

        do {
            // assert that pagination params are correct
            let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 1)
            XCTAssertEqual(call?.query.filter.unwrapped?.isArchived.unwrapped, true)
            XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, "cursor-2")
        }

        do {
            let call: MockApolloClient.FetchCall<SavedItemSummariesQuery>? = apollo.fetchCall(at: 2)
            XCTAssertNotNil(call)
            XCTAssertEqual(call?.query.pagination.unwrapped?.after.unwrapped, "cursor-4")
        }
    }

    func test_multipleRequestsForSamePage_queuesEachRequest() {
        // setup service
        let service = subject()

        // fetch the initial page
        let initialLoad = expectation(description: "initialLoad")
        service.results.dropFirst().first().sink { items in
            initialLoad.fulfill()
        }.store(in: &subscriptions)

        let secondLoad = expectation(description: "secondLoad")
        secondLoad.isInverted = true
        service.results.dropFirst(2).first().sink { items in
            secondLoad.fulfill()
        }.store(in: &subscriptions)

        service.fetch()
        service.fetch()

        wait(for: [initialLoad, secondLoad], timeout: 1)
        XCTAssertEqual(apollo.fetchCalls(withQueryType: SavedItemSummariesQuery.self).count, 1)
    }

    func test_handlingUpdatedSavedItems_sendsEvent() throws {
        let savedItem = try space.createSavedItem(isFavorite: false, isArchived: true)
        try space.save()

        let service = subject()

        let itemUpdated = expectation(description: "itemUpdated")
        service.itemUpdated.sink { updatedItem in
            defer { itemUpdated.fulfill() }
            XCTAssertEqual(updatedItem, savedItem)
        }.store(in: &subscriptions)

        let newResults = expectation(description: "newResults")
        newResults.isInverted = true
        service.results.dropFirst().sink { _ in
            newResults.fulfill()
        }.store(in: &subscriptions)

        savedItem.isFavorite = true
        try space.save()

        wait(for: [itemUpdated, newResults], timeout: 1)
    }

    func test_settingFilters_resetsLocalStorageAndFetchesContentFromServer() throws {
        setupArchivePagination()
        let service = subject()

        service.results.sink { results in
            print(results)
        }.store(in: &subscriptions)

        let allContentLoaded = expectation(description: "allContentLoaded")
        service.results.dropFirst(3).first().sink { results in
            allContentLoaded.fulfill()
        }.store(in: &subscriptions)

        service.fetch(at: [4])
        wait(for: [allContentLoaded], timeout: 1)

        apollo.stubFetch(
            toReturnFixtureNamed: "archived-favorited-items",
            asResultType: SavedItemSummariesQuery.self
        )

        let emptyContent = expectation(description: "emptyContent")
        service.results.dropFirst().first().sink { results in
            defer { emptyContent.fulfill() }
            XCTAssertEqual(results, [])
        }.store(in: &subscriptions)

        let favoritedContentLoaded = expectation(description: "favoriteContentLoaded")
        service.results.dropFirst(2).first().sink { results in
            defer { favoritedContentLoaded.fulfill() }
            XCTAssertEqual(results.count, 2)

            do {
                guard !results.isEmpty, case .loaded(let savedItem) = results[0] else {
                    XCTFail("Expected a loaded result but got a non loaded result")
                    return
                }

                XCTAssertEqual(savedItem.remoteID, "archived-favorited-saved-item-1")
            }

            do {
                guard !results.isEmpty, case .loaded(let savedItem) = results[1] else {
                    XCTFail("Expected a loaded result but got a non loaded result")
                    return
                }

                XCTAssertEqual(savedItem.remoteID, "archived-favorited-saved-item-0")
            }
        }.store(in: &subscriptions)

        service.filters = [.favorites]
        wait(for: [emptyContent, favoritedContentLoaded], timeout: 1, enforceOrder: true)
    }

    func test_refresh_clearsCachedItems_andFetchesFirstPage() {
        setupArchivePagination()
        let service = subject()

        service.results.sink { results in
            print(results)
        }.store(in: &subscriptions)

        let allContentLoaded = expectation(description: "allContentLoaded")
        service.results.dropFirst(3).first().sink { results in
            allContentLoaded.fulfill()
        }.store(in: &subscriptions)

        service.fetch(at: [4])
        wait(for: [allContentLoaded], timeout: 1)

        let emptyContent = expectation(description: "emptyContent")
        service.results.dropFirst().first().sink { results in
            defer { emptyContent.fulfill() }
            XCTAssertEqual(results, [])

        }.store(in: &subscriptions)

        let refreshedContent = expectation(description: "refreshedContent")
        service.results.dropFirst(2).first().sink { results in
            defer { refreshedContent.fulfill() }
            XCTAssertEqual(results.count, 5)
        }.store(in: &subscriptions)

        let completionInvoked = expectation(description: "completionInvoked")
        service.refresh {
            defer { completionInvoked.fulfill() }
            XCTAssertTrue(Thread.isMainThread)
        }

        wait(for: [emptyContent, refreshedContent, completionInvoked], timeout: 1)
    }
}

extension PocketArchiveServiceTests {
    func setupArchivePagination() {
        apollo.stubFetch { (query: SavedItemSummariesQuery, _, _, queue, completion) in
            let resultFixtureName: String
            switch query.pagination.after {
            case nil:
                resultFixtureName = "archived-items"
            case .some(let cursor):
                switch cursor {
                case .none:
                    resultFixtureName = "archived-items"
                case .some(let cursor):
                    switch cursor {
                    case "cursor-2":
                        resultFixtureName = "archived-items-page-2"
                    case "cursor-4":
                        resultFixtureName = "archived-items-page-3"
                    default:
                        fatalError("Unexpected pagination cursor: \(cursor)")
                    }
                case .null:
                    fatalError("Unexpected pagination cursor: \(cursor)")
                }
            }

            queue.async {
                let fixture = Fixture.load(name: resultFixtureName)
                let graphQLResult = fixture.asGraphQLResult(from: query)

                completion?(.success(graphQLResult))
            }

            return MockCancellable()
        }
    }
}
