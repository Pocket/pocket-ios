import XCTest


extension PocketSourceTests {
    func test_initialization_startsMonitoringNetworkPath() {
        _ = subject()
        XCTAssertTrue(networkMonitor.wasStartCalled)
    }

    func test_enqueueingOperations_whenNetworkPathIsUnsatisfied_doesNotExecuteOperations() {
        sessionProvider.session = MockSession()
        operations.stubFetchArchivePage { _, _, _, _, _ in
            return BlockOperation {
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
            return BlockOperation {
                expectFetchArchive.fulfill()
            }
        }

        let expectFetchList = expectation(description: "execute the fetch list operation")
        operations.stubFetchList { _, _, _, _, _ in
            return BlockOperation {
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
}
