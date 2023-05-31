// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import PocketGraph

@testable import Sync

extension PocketSourceTests {
    func test_restoresOperationsInCorrectOrder() throws {
        sessionProvider.session = MockSession()

        let fetchList = expectation(description: "fetchList operation executed")
        operations.stubFetchSaves { _, _, _, _  in
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

        source.refreshSaves()
        source.favorite(item: item)
        source.archive(item: item)

        source = nil
        source = subject()
        source.restore()
        networkMonitor.update(status: .satisfied)

        wait(for: [favoriteItem, archiveItem], timeout: 5, enforceOrder: true)
        wait(for: [fetchList], timeout: 5)

        let done = expectation(description: "done")
        source.drain { done.fulfill() }
        wait(for: [done], timeout: 5)

        _ = XCTWaiter.wait(for: [expectation(description: "Waiting for core data to flush deletions")], timeout: 5.0)

        operations.stubFetchSaves { _, _, _, _  in
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
