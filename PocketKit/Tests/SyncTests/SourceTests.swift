// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
import Apollo
import Combine

@testable import Sync

enum TestError: Error {
    case anError
}

class SourceTests: XCTestCase {
    var client: MockApolloClient!
    var source: Source!
    var cancellables: Set<AnyCancellable> = []

    static let container: NSPersistentContainer = {
        let url = Bundle.sync.url(forResource: "PocketModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        let container = NSPersistentContainer(name: "PocketModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        container.persistentStoreDescriptions = [description]

        return container
    }()

    var container: NSPersistentContainer {
        Self.container
    }
    
    override func setUpWithError() throws {
        for store in container.persistentStoreCoordinator.persistentStores {
            try container.persistentStoreCoordinator.remove(store)
        }

        client = MockApolloClient()
        source = Source(
            apollo: client,
            container: container
        )

        source.clear()
    }

    override func tearDown() {
        cancellables = []
    }

    private func configureMockClientToFail(withError expectedError: TestError, assertions: @escaping (Error) -> ()) {
        let expectError = expectation(description: "Expecting error")
        source.syncEvents.sink { event in
            guard case .error(let actualError) = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            assertions(actualError)
            expectError.fulfill()
        }.store(in: &cancellables)

        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            completion?(.failure(expectedError))
            return MockCancellable()
        }
    }

    private func configureMockClientToReturnFixture(named fixtureName: String) {
        let expectCompletion = expectation(description: "Expect sync completion")
        source.syncEvents.sink { event in
            if case .finished = event {
                expectCompletion.fulfill()
            }
        }.store(in: &cancellables)

        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            let result = Fixture.load(name: fixtureName).asGraphQLResult(from: query)
            completion?(.success(result))

            return MockCancellable()
        }
    }

    func test_refresh_fetchesUserByTokenQueryWithGivenTokenAndFilteringOutArchivedItems() {
        configureMockClientToReturnFixture(named: "list")
        source.refresh(token: "the-token")
        waitForExpectations(timeout: 1)

        XCTAssertFalse(client.fetchCalls.isEmpty)
        let call: MockApolloClient.FetchCall<UserByTokenQuery> = client.fetchCall(at: 0)
        XCTAssertEqual(call.query.token, "the-token")
        XCTAssertEqual(call.query.savedItemsFilter?.isArchived, false)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() throws {
        configureMockClientToReturnFixture(named: "list")
        source.refresh(token: "the-token")
        waitForExpectations(timeout: 1)

        let request = Requests.fetchAllItems()
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items.count, 2)

        do {
            let item = items[0]
            XCTAssertEqual(item.itemID, "item-id-1")
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
        source.refresh(token: "the-token")
        waitForExpectations(timeout: 1)

        let request = Requests.fetchAllItems()
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistingItems() throws {
        // set up the context with an existing item
        let itemURL = URL(string: "http://example.com/item-1")!
        let item = Item(context: container.viewContext)
        item.url = itemURL
        item.title = "Item 1"
        try container.viewContext.save()

        configureMockClientToReturnFixture(named: "updated-item")
        source.refresh(token: "the-token")
        waitForExpectations(timeout: 1)

        let request = Requests.fetchItem(byURLString: itemURL.absoluteString)
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items[0].title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() throws {
        let expectedError = TestError.anError
        configureMockClientToFail(withError: expectedError) { error in
            XCTAssertEqual(error as? TestError, expectedError)
        }

        source.refresh(token: "the-token")
        waitForExpectations(timeout: 1.0)
    }

    func test_refresh_whenResponseIncludesMultiplePages_fetchesNextPage() throws {
        let finishSync = expectation(description: "Finish sync")
        source.syncEvents.sink { event in
            guard case .finished = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            finishSync.fulfill()
        }.store(in: &cancellables)

        var fetches = 0
        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
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

        source.refresh(token: "the-token")
        waitForExpectations(timeout: 1.0)

        let request = Requests.fetchAllItems()
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items.count, 2)
    }

    func test_refresh_whenItemCountExceedsMax_fetchesMaxNumberOfItems() throws {
        let finishSync = expectation(description: "Finish sync")
        source.syncEvents.sink { event in
            guard case .finished = event else {
                XCTFail("Received unexpected event: \(event)")
                return
            }

            finishSync.fulfill()
        }.store(in: &cancellables)

        var fetches = 0
        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
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

        source.refresh(token: "the-token", maxItems: 3)
        waitForExpectations(timeout: 1)

        let request = Requests.fetchAllItems()
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items.count, 3)
    }
}
