import XCTest
import PocketGraph

@testable import Sync

extension PocketSourceTests {
    func test_restoresOperationsInCorrectOrder() throws {
        sessionProvider.session = MockSession()

        let fetchList = expectation(description: "fetchList operation executed")
        operations.stubFetchList { _, _, _, _, _, _ in
            TestSyncOperation { fetchList.fulfill() }
        }

        let favoriteItem = expectation(description: "favorite operation executed")
        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            TestSyncOperation { favoriteItem.fulfill() }
        }

        let archiveItem = expectation(description: "archive operation executed")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            TestSyncOperation { archiveItem.fulfill() }
        }

        let item = try space.createSavedItem()

        var source: PocketSource! = subject()
        networkMonitor.update(status: .unsatisfied)

        source.refresh()
        source.favorite(item: item)
        source.archive(item: item)

        source = nil
        source = subject()
        source.restore()
        networkMonitor.update(status: .satisfied)

        wait(for: [fetchList, favoriteItem, archiveItem], timeout: 1, enforceOrder: true)

        let done = expectation(description: "done")
        source.drain { done.fulfill() }
        wait(for: [done], timeout: 1)

        operations.stubFetchList { _, _, _, _, _, _ in
            XCTFail("Operation should not be re-created after succeeding")
            return TestSyncOperation { }
        }
        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            XCTFail("Operation should not be re-created after succeeding")
            return TestSyncOperation { }
        }
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            XCTFail("Operation should not be re-created after succeeding")
            return TestSyncOperation { }
        }

        source = nil
        source = subject()
        source.restore()
    }
}
