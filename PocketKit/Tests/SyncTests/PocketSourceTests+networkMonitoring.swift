import XCTest
import PocketGraph
@testable import Sync

extension PocketSourceTests {
    func test_initialization_startsMonitoringNetworkPath() {
        _ = subject()
        XCTAssertTrue(networkMonitor.wasStartCalled)
    }

    func test_enqueueingOperations_whenNetworkPathIsUnsatisfied_doesNotExecuteOperations() {
        sessionProvider.session = MockSession()
        operations.stubFetchList { _, _, _, _, _, _ in
            TestSyncOperation {
                XCTFail("Operation should not be executed while network path is unsatisfied")
            }
        }

        let source = subject()
        networkMonitor.update(status: .unsatisfied)

        source.refresh()
    }

    func test_enqueueingOperations_whenNetworkBecomesSatisfied_executesPendingOperations() {
        sessionProvider.session = MockSession()

        let expectSaveItem = expectation(description: "execute the save item operation")
        operations.stubSaveItemOperation { _, _, _, _, _ in
            TestSyncOperation {
                expectSaveItem.fulfill()
            }
        }

        let expectFetchList = expectation(description: "execute the fetch list operation")
        operations.stubFetchList { _, _, _, _, _, _ in
            TestSyncOperation {
                expectFetchList.fulfill()
            }
        }

        let source = subject()
        networkMonitor.update(status: .unsatisfied)

        source.save(item: space.buildSavedItem())
        source.refresh()

        networkMonitor.update(status: .satisfied)
        wait(for: [expectSaveItem, expectFetchList], timeout: 1, enforceOrder: true)
    }

    func test_whenNetworkBecomesSatisified_retriesOperationsThatAreWaitingForSignal() throws {
        var attempts = 0

        let firstAttempt = expectation(description: "first attempt")
        let retrySignalSent = expectation(description: "send retry signal")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            TestSyncOperation { () -> SyncOperationResult in
                print("trying: \(attempts)")
                defer { attempts += 1 }

                switch attempts {
                case 0:
                    firstAttempt.fulfill()
                    return .retry(TestError.anError)
                case 1:
                    retrySignalSent.fulfill()
                    return .success
                default:
                    XCTFail("Unexpected number of attempts: \(attempts)")
                    return .failure(TestError.anError)
                }
            }
        }

        let source = subject()
        try source.archive(item: space.createSavedItem())
        wait(for: [firstAttempt], timeout: 1)

        networkMonitor.update(status: .unsatisfied)
        networkMonitor.update(status: .satisfied)
        wait(for: [retrySignalSent], timeout: 1)
    }

    func test_whenAnActionIsTaken_andNetworkPathIsSatisified_retriesOperationsThatAreWaitingForSignal() throws {
        var attempts = 0

        let firstAttempt = expectation(description: "first attempt")
        let retrySignalSent = expectation(description: "send retry signal")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            TestSyncOperation { () -> SyncOperationResult in
                print("trying: \(attempts)")
                defer { attempts += 1 }

                switch attempts {
                case 0:
                    firstAttempt.fulfill()
                    return .retry(TestError.anError)
                case 1:
                    retrySignalSent.fulfill()
                    return .success
                default:
                    XCTFail("Unexpected number of attempts: \(attempts)")
                    return .failure(TestError.anError)
                }
            }
        }

        let attemptFavorite = expectation(description: "favorite")
        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            TestSyncOperation { () -> SyncOperationResult in
                attemptFavorite.fulfill()
                return .success
            }
        }

        let item = try space.createSavedItem()
        let source = subject()
        source.archive(item: item)
        wait(for: [firstAttempt], timeout: 1)

        source.favorite(item: item)
        wait(for: [retrySignalSent, attemptFavorite], timeout: 1, enforceOrder: true)
    }

    func test_whenAnActionIsTaken_andNetworkPathIsNotSatisified_doesNotRetryOperationsThatAreWaitingForSignal() throws {
        var attempts = 0

        let firstAttempt = expectation(description: "first attempt")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            TestSyncOperation { () -> SyncOperationResult in
                defer { attempts += 1 }

                switch attempts {
                case 0:
                    firstAttempt.fulfill()
                    return .retry(TestError.anError)
                default:
                    XCTFail("Unexpected number of attempts: \(attempts)")
                    return .failure(TestError.anError)
                }
            }
        }

        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            TestSyncOperation { }
        }

        let item = try space.createSavedItem()
        let source = subject()
        source.archive(item: item)
        wait(for: [firstAttempt], timeout: 1)

        networkMonitor.update(status: .unsatisfied)
        source.favorite(item: item)
    }

    func test_retryImmediately_sendsRetrySignal() throws {
        var attempts = 0
        let firstAttempt = expectation(description: "first attempt")
        let retrySignalSent = expectation(description: "send retry signal")

        // Using a queue to fulfill the above expectations
        // gives us a to register a listener to the retry signal before actually triggering the retry
        let queue = DispatchQueue.global(qos: .background)

        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            TestSyncOperation { () -> SyncOperationResult in
                defer { attempts += 1 }

                switch attempts {
                case 0:
                    queue.async { firstAttempt.fulfill() }
                    return .retry(TestError.anError)
                case 1:
                    queue.async { retrySignalSent.fulfill() }
                    return .success
                default:
                    XCTFail("Unexpected number of attempts: \(attempts)")
                    return .failure(TestError.anError)
                }
            }
        }

        let item = try space.createSavedItem()
        let source = subject()
        source.archive(item: item)
        wait(for: [firstAttempt], timeout: 1)

        source.retryImmediately()
        wait(for: [retrySignalSent], timeout: 1)
    }
}
