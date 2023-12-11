// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
import Combine

@testable import Sync

class RetriableOperationTests: XCTestCase {
    var retrySignal: PassthroughSubject<Void, Never>!
    var backgroundTaskManager: MockBackgroundTaskManager!
    var space: Space!
    var task: PersistentSyncTask!

    override func setUpWithError() throws {
        try super.setUpWithError()
        retrySignal = .init()
        backgroundTaskManager = MockBackgroundTaskManager()
        space = .testSpace()
        task = PersistentSyncTask(context: space.backgroundContext)
        task.syncTaskContainer = SyncTaskContainer(task: .fetchSaves)
        try space.save()

        backgroundTaskManager.stubBeginTask { _, _ in return 0 }
        backgroundTaskManager.stubEndTask { _ in }
        XCTAssertEqual(try space.fetchPersistentSyncTasks().count, 1)
    }

    func subject(
        retrySignal: AnyPublisher<Void, Never>? = nil,
        backgroundTaskManager: BackgroundTaskManager? = nil,
        operation: SyncOperation,
        syncTaskId: NSManagedObjectID? = nil
    ) -> RetriableOperation {
        RetriableOperation(
            retrySignal: retrySignal ?? self.retrySignal.eraseToAnyPublisher(),
            backgroundTaskManager: backgroundTaskManager ?? self.backgroundTaskManager,
            operation: operation,
            space: self.space,
            syncTaskId: syncTaskId ?? self.task.objectID
        )
    }

    func test_retry_retriesOnSignal() throws {
        var calls = 0
        let firstAttempt = expectation(description: "first attempt")
        let secondAttempt = expectation(description: "second attempt")

        let operation = TestSyncOperation { () -> SyncOperationResult in
            defer { calls += 1 }

            switch calls {
            case 0:
                firstAttempt.fulfill()
                return .retry(TestError.anError)
            case 1:
                secondAttempt.fulfill()
                return .success
            default:
                XCTFail("Received unexpected number of calls: \(calls)")
                return .failure(TestError.anError)
            }
        }

        let completed = expectation(description: "it completed")
        let executor = subject(operation: operation)
        executor.completionBlock = {
            completed.fulfill()
        }

        let queue = OperationQueue()
        queue.addOperation(executor)

        wait(for: [firstAttempt], timeout: 10)
        // NOTE: We need to await after the firstAttempt because it takes a few ms for the
        // retrySubscritpion to get setup after firstAttempt is fullfilled.
        // TODO: Refactor retrySignal to keep track of its number of subscribers and instead wait for that to become 1 instead of this random wait.
        _ = XCTWaiter.wait(for: [expectation(description: "wait for subscriber")], timeout: 1)
        retrySignal.send()
        wait(for: [secondAttempt, completed], timeout: 5, enforceOrder: true)
        XCTAssertEqual(try space.fetchPersistentSyncTasks().count, 0)
    }

    func test_retry_whenMaxRetriesAreExceeded_doesNotRetry() {
        var calls = 0

        let expectations = [
            expectation(description: "first attempt"),
            expectation(description: "second attempt"),
            expectation(description: "third attempt"),
        ]

        let operation = TestSyncOperation { () -> SyncOperationResult in
            guard calls <= 3 else {
                XCTFail("Max retries exceeded")
                return .failure(TestError.anError)
            }

            expectations[calls].fulfill()
            calls += 1
            return .retry(TestError.anError)
        }

        let executor = subject(operation: operation)
        let completed = expectation(description: "it completed")
        executor.completionBlock = {
            completed.fulfill()
        }
        let queue = OperationQueue()
        queue.addOperation(executor)

        expectations.forEach {
            wait(for: [$0], timeout: 10)
            // NOTE: We need to await after each attempt because it takes a few ms for the
            // retrySubscritpion to get setup after the attempt is fullfilled.
            // TODO: Refactor retrySignal to keep track of its number of subscribers and instead wait for that to become 1 instead of this random wait.
            _ = XCTWaiter.wait(for: [expectation(description: "wait for subscriber")], timeout: 1)
            retrySignal.send()
        }

        wait(for: [completed], timeout: 10, enforceOrder: true)
        XCTAssertEqual(try space.fetchPersistentSyncTasks().count, 0)
    }
}
