import XCTest
import Combine
@testable import Sync


class RetriableOperationTests: XCTestCase {
    func test_retry_retriesOnSignal() {
        var calls = 0
        let retrySignal: PassthroughSubject<Void, Never> = PassthroughSubject()
        let firstAttempt = expectation(description: "first attempt")
        let secondAttempt = expectation(description: "second attempt")

        let operation = TestSyncOperation { () -> SyncOperationResult in
            defer { calls += 1 }

            switch calls {
            case 0:
                firstAttempt.fulfill()
                return .retry
            case 1:
                secondAttempt.fulfill()
                return .success
            default:
                XCTFail("Received unexpected number of calls: \(calls)")
                return .failure(TestError.anError)
            }
        }

        let executor = RetriableOperation(
            retrySignal: retrySignal.eraseToAnyPublisher(),
            operation: operation
        )

        let completed = expectation(description: "it completed")
        let queue = OperationQueue()
        queue.addOperation(executor)
        queue.addBarrierBlock {
            completed.fulfill()
        }

        wait(for: [firstAttempt], timeout: 1)
        retrySignal.send()
        wait(for: [secondAttempt, completed], timeout: 1, enforceOrder: true)
    }

    func test_retry_whenMaxRetriesAreExceeded_doesNotRetry() {
        var calls = 0
        let retrySignal: PassthroughSubject<Void, Never> = PassthroughSubject()

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
            return .retry
        }

        let executor = RetriableOperation(
            retrySignal: retrySignal.eraseToAnyPublisher(),
            operation: operation
        )

        let completed = expectation(description: "it completed")
        let queue = OperationQueue()
        queue.addOperation(executor)
        queue.addBarrierBlock {
            completed.fulfill()
        }

        expectations.forEach {
            wait(for: [$0], timeout: 1)
            retrySignal.send()
        }

        wait(for: [completed], timeout: 1, enforceOrder: true)
    }
}
