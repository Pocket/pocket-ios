// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Apollo
import PocketGraph
import Combine
import CoreData

@testable import Sync

class SaveItemOperationTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var subscriptions: [AnyCancellable] = []
    var queue: OperationQueue!
    var events: SyncEvents!
    var task: PersistentSyncTask!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apollo = MockApolloClient()
        space = .testSpace()
        queue = OperationQueue()
        events = PassthroughSubject()
        task = PersistentSyncTask(context: space.backgroundContext)
        task.syncTaskContainer = SyncTaskContainer(task: .fetchSaves)
        try space.save()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        managedItemID: NSManagedObjectID,
        url: URL,
        events: SyncEvents? = nil,
        apollo: ApolloClientProtocol? = nil,
        space: Space? = nil
    ) -> SaveItemOperation {
        SaveItemOperation(
            managedItemID: managedItemID,
            url: url,
            events: events ?? self.events,
            apollo: apollo ?? self.apollo,
            space: space ?? self.space
        )
    }

    func test_main_performsSaveItemMutation_andUpdatesLocalStorage() async throws {
        let url = URL(string: "http://example.com/add-me-to-your-list")!
        let savedItem = try space.createSavedItem(
            remoteID: "saved-item-1",
            item: space.buildItem(givenURL: url.absoluteString)
        )

        apollo.stubPerform(
            toReturnFixtureNamed: "save-item",
            asResultType: SaveItemMutation.self
        )

        let service = subject(managedItemID: savedItem.objectID, url: url)
        _ = await service.execute(syncTaskId: task.objectID)
        _ = await service.execute(syncTaskId: task.objectID)
        _ = await service.execute(syncTaskId: task.objectID)
        _ = await service.execute(syncTaskId: task.objectID)

        let items = try? space.fetchItems()
        XCTAssertEqual(items?.count, 1)

        let performCall: MockApolloClient.PerformCall<SaveItemMutation>? = apollo.performCall(at: 0)
        XCTAssertNotNil(performCall)
        XCTAssertEqual(performCall?.mutation.input.url, url.absoluteString)

        let item = try space.fetchSavedItem(byURL: url)
        XCTAssertEqual(savedItem.item?.resolvedURL, "https://resolved.example.com/item-1")
        XCTAssertNotNil(item)
    }

    func test_main_whenMutationFails_withUnknownError_returnsErrorStatus() async throws {
        let savedItem = try space.createSavedItem(remoteID: "saved-item-1")

        apollo.stubPerform(
            ofMutationType: SaveItemMutation.self,
            toReturnError: TestError.anError
        )

        let service = subject(managedItemID: savedItem.objectID, url: savedItem.url)
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .failure = result else {
            XCTFail("Expected failure result but got \(result)")
            return
        }
    }

    func test_main_whenMutationFailsWithHTTP5XX_does_not_retry() async throws {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        apollo.stubPerform(ofMutationType: SaveItemMutation.self, toReturnError: initialError)

        let savedItem = try space.createSavedItem()
        let service = subject(managedItemID: savedItem.objectID, url: savedItem.url)
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .failure = result else {
            XCTFail("Expected failure result but got \(result)")
            return
        }
    }

    func test_main_whenClientSideNetworkFails_retries() async throws {
        let initialError = URLSessionClient.URLSessionClientError.networkError(
            data: Data(),
            response: nil,
            underlying: TestError.anError
        )

        apollo.stubPerform(ofMutationType: SaveItemMutation.self, toReturnError: initialError)

        let savedItem = try space.createSavedItem()
        let service = subject(managedItemID: savedItem.objectID, url: savedItem.url)
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }
}
