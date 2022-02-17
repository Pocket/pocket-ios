import XCTest
@testable import Sync


extension PocketSourceTests {
    func test_initialization_startsMonitoringNetworkPath() {
        _ = subject()
        XCTAssertTrue(networkMonitor.wasStartCalled)
    }

    func test_enqueueingOperations_whenNetworkPathIsUnsatisfied_doesNotExecuteOperations() {
        sessionProvider.session = MockSession()
        operations.stubFetchArchivePage { _, _, _, _, _ in
            TestSyncOperation {
                XCTFail("Operation should not be executed while network path is unsatisfied")
            }
        }

        let source = subject()
        networkMonitor.update(status: .unsatisfied)

        source.fetchArchivePage(cursor: "", isFavorite: nil)
    }

    func test_enqueueingOperations_whenNetworkBecomesSatisfied_executesPendingOperations() {
        sessionProvider.session = MockSession()


        let expectFetchArchive = expectation(description: "execute the fetch archive operation")
        operations.stubFetchArchivePage { _, _, _, _, _ in
            TestSyncOperation {
                expectFetchArchive.fulfill()
            }
        }

        let expectFetchList = expectation(description: "execute the fetch list operation")
        operations.stubFetchList { _, _, _, _, _ in
            TestSyncOperation {
                expectFetchList.fulfill()
            }
        }

        let source = subject()
        networkMonitor.update(status: .unsatisfied)

        source.fetchArchivePage(cursor: "", isFavorite: nil)
        source.refresh()

        networkMonitor.update(status: .satisfied)
        wait(for: [expectFetchArchive, expectFetchList], timeout: 1, enforceOrder: true)
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
                    return .retry
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
        try source.archive(item: space.seedSavedItem())
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
                    return .retry
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

        let item = try space.seedSavedItem()
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
                    return .retry
                default:
                    XCTFail("Unexpected number of attempts: \(attempts)")
                    return .failure(TestError.anError)
                }
            }
        }

        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            TestSyncOperation { }
        }

        let item = try space.seedSavedItem()
        let source = subject()
        source.archive(item: item)
        wait(for: [firstAttempt], timeout: 1)

        networkMonitor.update(status: .unsatisfied)
        source.favorite(item: item)
    }
}
