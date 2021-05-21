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
    var errorSubject: PassthroughSubject<Error, Never>!
    var cancellables: Set<AnyCancellable> = []

    static let container: NSPersistentContainer = {
        let url = Bundle(for: Item.self).url(forResource: "PocketModel", withExtension: "momd")!
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
        errorSubject = PassthroughSubject()
        source = Source(
            apollo: client,
            container: container,
            errorSubject: errorSubject
        )

        source.clear()
    }

    override func tearDown() {
        cancellables = []
    }

    func test_refresh_fetchesUserByTokenQueryWithGivenToken() {
        client.stubFetch { (_: UserByTokenQuery, _, _, _, _) -> Apollo.Cancellable in
            return MockCancellable()
        }

        source.refresh(token: "the-token")

        XCTAssertFalse(client.fetchCalls.isEmpty)
        let call: MockApolloClient.FetchCall<UserByTokenQuery> = client.fetchCall(at: 0)
        XCTAssertEqual(call.query.token, "the-token")
    }

    func test_refresh_whenFetchSucceeds_andResultContainsNewItems_createsNewItems() throws {
        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            let result = Fixture.load(name: "list").asGraphQLResult(from: query)
            completion?(.success(result))

            return MockCancellable()
        }

        source.refresh(token: "the-token")

        let request = Requests.fetchItems()
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items.count, 2)

        // TODO: Assert on item content
    }
    
    func test_refresh_whenFetchSucceeds_andResultContainsDuplicateItems_createsSingleItem() throws {
        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            let result = Fixture.load(name: "duplicate-list").asGraphQLResult(from: query)
            completion?(.success(result))

            return MockCancellable()
        }

        source.refresh(token: "the-token")

        let request = Requests.fetchItems()
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items.count, 1)
    }

    func test_refresh_whenFetchSucceeds_andResultContainsUpdatedItems_updatesExistsItems() throws {
        // set up the context with an existing item
        let itemURL = URL(string: "http://example.com/item-1")!
        let item = Item(context: container.viewContext)
        item.url = itemURL
        item.title = "Item 1"
        try container.viewContext.save()

        client.stubFetch { (query: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            let result = Fixture.load(name: "updated-item").asGraphQLResult(from: query)
            completion?(.success(result))

            return MockCancellable()
        }

        source.refresh(token: "the-token")

        let request = Requests.fetchItem(byURLString: itemURL.absoluteString)
        let items = try container.viewContext.fetch(request)
        XCTAssertEqual(items[0].title, "Updated Item 1")
    }

    func test_refresh_whenFetchFails_sendsErrorOverGivenSubject() throws {
        let expectError = expectation(description: "Expecting error")
        errorSubject.sink { error in
            XCTAssertEqual(error as? TestError, TestError.anError)
            expectError.fulfill()
        }.store(in: &cancellables)

        client.stubFetch { (_: UserByTokenQuery, _, _, _, completion) -> Apollo.Cancellable in
            completion?(.failure(TestError.anError))
            return MockCancellable()
        }

        source.refresh(token: "the-token")

        waitForExpectations(timeout: 1.0)
    }
}
