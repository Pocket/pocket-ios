// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
import Apollo
import Combine

@testable import Sync


class SourceTests: XCTestCase {
    var space: Space!
    var apollo: MockApolloClient!
    var operations: MockOperationFactory!

    override func setUpWithError() throws {
        space = Space(container: .testContainer)
        apollo = MockApolloClient()
        operations = MockOperationFactory()
    }

    func test_refresh_addsFetchListOperationToQueue() {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubFetchList { _, _, _, _, _ in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )

        source.refresh(token: "test-token")
        waitForExpectations(timeout: 1)
    }

    func test_favorite_togglesIsFavorite_andExecutesFavoriteMutation() throws {
        let item = try space.seedItem(itemID: "test-item-id")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: FavoriteItemMutation) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )
        source.favorite(item: item)

        XCTAssertTrue(item.isFavorite)
        waitForExpectations(timeout: 1)
    }

    func test_unfavorite_unsetsIsFavorite_andExecutesUnfavoriteMutation() throws {
        let item = try space.seedItem()
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: UnfavoriteItemMutation) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )
        source.unfavorite(item: item)

        XCTAssertFalse(item.isFavorite)
        waitForExpectations(timeout: 1)
    }

    func test_delete_removesItemFromLocalStorage_andExecutesDeleteMutation() throws {
        let item = try space.seedItem(itemID: "delete-me")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: DeleteItemMutation) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )
        source.delete(item: item)

        let fetchedItem = try space.fetchItem(byItemID: "delete-me")
        XCTAssertNil(fetchedItem)
        XCTAssertFalse(item.hasChanges)
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func tests_archive_removesItemFromLocalStorage_andExecutesArchiveMutation() throws {
        let item = try space.seedItem(itemID: "archive-me")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: ArchiveItemMutation) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )
        source.archive(item: item)

        let fetchedItem = try space.fetchItem(byItemID: "archive-me")
        XCTAssertNil(fetchedItem)
        XCTAssertFalse(item.hasChanges)
        wait(for: [expectationToRunOperation], timeout: 1)
    }
}
