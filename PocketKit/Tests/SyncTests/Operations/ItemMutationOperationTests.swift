// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Apollo
import ApolloAPI
import PocketGraph
import Combine

@testable import Sync

class ItemMutationOperationTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var subscriptions: [AnyCancellable] = []
    var queue: OperationQueue!
    var events: SyncEvents!
    var task: CDPersistentSyncTask!

    override func setUpWithError() throws {
        try super.setUpWithError()
        apollo = MockApolloClient()
        space = .testSpace()
        queue = OperationQueue()
        events = PassthroughSubject()
        task = CDPersistentSyncTask(context: space.backgroundContext)
        task.syncTaskContainer = SyncTaskContainer(task: .fetchSaves)
        try space.save()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
        try super.tearDownWithError()
    }

    func subject<Mutation: GraphQLMutation>(
        mutation: Mutation,
        apollo: ApolloClientProtocol? = nil,
        events: SyncEvents? = nil
    ) -> SavedItemMutationOperation {
        SavedItemMutationOperation(
            apollo: apollo ?? self.apollo,
            events: events ?? self.events,
            mutation: mutation
        )
    }

    func test_operation_performsGivenMutation() async throws {
        let savedItem = try space.createSavedItem(remoteID: "test-item-id")

        apollo.stubPerform(
            toReturnFixtureNamed: "archive",
            asResultType: ArchiveItemMutation.self
        )

        let mutation = ArchiveItemMutation(
            givenUrl: savedItem.url,
            timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
        )
        let service = subject(mutation: mutation)
        _ = await service.execute(syncTaskId: task.objectID)

        let call = apollo.performCall(
            withMutationType: ArchiveItemMutation.self,
            at: 0
        )

        XCTAssertEqual(call?.mutation.givenUrl, savedItem.url)
    }

    func test_operation_whenMutationFails_propagatesError() async throws {
        let savedItem = try space.createSavedItem()

        apollo.stubPerform(
            ofMutationType: ArchiveItemMutation.self,
            toReturnError: TestError.anError
        )

        var error: Error?
        events.sink { event in
            guard case .error(let e) = event else {
                return
            }

            error = e
        }.store(in: &subscriptions)

        let mutation = ArchiveItemMutation(
            givenUrl: savedItem.url,
            timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
        )
        let service = subject(mutation: mutation)
        _ = await service.execute(syncTaskId: task.objectID)

        XCTAssertNotNil(error)
        XCTAssertEqual(error as? TestError, .anError)
    }

    func test_execute_whenMutationFailsWithHTTP5XX_retries() async throws {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        apollo.stubPerform(ofMutationType: ArchiveItemMutation.self, toReturnError: initialError)

        let savedItem = try space.createSavedItem()
        let mutation = ArchiveItemMutation(
            givenUrl: savedItem.url,
            timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
        )
        let service = subject(mutation: mutation)
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .failure = result else {
            XCTFail("Expected failure result but got \(result)")
            return
        }
    }

    func test_execute_whenClientSideNetworkFails_retries() async throws {
        let initialError = URLSessionClient.URLSessionClientError.networkError(
            data: Data(),
            response: nil,
            underlying: TestError.anError
        )

        apollo.stubPerform(ofMutationType: ArchiveItemMutation.self, toReturnError: initialError)

        let savedItem = try space.createSavedItem()
        let mutation = ArchiveItemMutation(
            givenUrl: savedItem.url,
            timestamp: ISO8601DateFormatter.pocketGraphFormatter.string(from: .now)
        )
        let service = subject(mutation: mutation)
        let result = await service.execute(syncTaskId: task.objectID)

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }
}
