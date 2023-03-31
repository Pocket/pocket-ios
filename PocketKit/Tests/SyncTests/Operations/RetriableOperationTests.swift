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

        wait(for: [firstAttempt], timeout: 1)
        // NOTE: We need to await after the firstAttempt because it takes a few ms for the
        // retrySubscritpion to get setup after firstAttempt is fullfilled.
        _ = XCTWaiter.wait(for: [expectation(description: "test")], timeout: 1)
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
            wait(for: [$0], timeout: 1)
            // NOTE: We need to await after each attempt because it takes a few ms for the
            // retrySubscritpion to get setup after the attempt is fullfilled.
            _ = XCTWaiter.wait(for: [expectation(description: "test")], timeout: 1)
            retrySignal.send()
        }

        wait(for: [completed], timeout: 1, enforceOrder: true)
        XCTAssertEqual(try space.fetchPersistentSyncTasks().count, 0)
    }

    func test_main_protectsOperationWithBackgroundTask() {
        let beganOperation = expectation(description: "began operation")
        let operation = TestSyncOperation {
            beganOperation.fulfill()
        }

        let executor = subject(operation: operation)

        let queue = OperationQueue()
        queue.addOperation(executor)

        wait(for: [beganOperation], timeout: 1)
        XCTAssertNotNil(backgroundTaskManager.beginTaskCall(at: 0))

        queue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(backgroundTaskManager.endTaskCall(at: 0)?.identifier, 0)
        XCTAssertEqual(try space.fetchPersistentSyncTasks().count, 0)
    }
}
