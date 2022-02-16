import XCTest
@testable import Sync


extension PocketSourceTests {
    func test_itDoesTheThing() throws {
        tokenProvider.accessToken = "test-token"

        let fetchList = expectation(description: "fetchList operation executed")
        operations.stubFetchList { _, _, _, _, _ in
            BlockOperation { fetchList.fulfill() }
        }

        let favoriteItem = expectation(description: "favorite operation executed")
        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            BlockOperation { favoriteItem.fulfill() }
        }

        let archiveItem = expectation(description: "archive operation executed")
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            BlockOperation { archiveItem.fulfill() }
        }

        let item = try space.seedSavedItem()

        var source: PocketSource! = subject()
        networkMonitor.update(status: .unsatisfied)

        source.refresh()
        source.favorite(item: item)
        source.archive(item: item)

        source = nil
        source = subject()
        networkMonitor.update(status: .satisfied)

        wait(for: [fetchList, favoriteItem, archiveItem], timeout: 1, enforceOrder: true)

        let done = expectation(description: "done")
        source.drain { done.fulfill() }
        wait(for: [done], timeout: 1)

        operations.stubFetchList { _, _, _, _, _ in
            XCTFail("Operation should not be re-created after succeeding")
            return BlockOperation { }
        }
        operations.stubItemMutationOperation { (_, _, _: FavoriteItemMutation) in
            XCTFail("Operation should not be re-created after succeeding")
            return BlockOperation { }
        }
        operations.stubItemMutationOperation { (_, _, _: ArchiveItemMutation) in
            XCTFail("Operation should not be re-created after succeeding")
            return BlockOperation { }
        }

        source = nil
        source = subject()
    }
}
