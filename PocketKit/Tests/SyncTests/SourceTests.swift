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

    func test_favorite_togglesIsFavorite_andAddsFavoriteItemOperationToQueue() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubFavoriteItem { _, _, _, _ in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )

        let item = space.newItem()
        item.itemID = "test-item-id"
        try space.save()

        source.favorite(item: item)
        XCTAssertTrue(item.isFavorite)

        waitForExpectations(timeout: 1)
    }

    func test_unfavorite_unsetsIsFavorite_andAddsUnfavoriteItemOperationToQueue() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubUnfavoriteItem { _, _, _, _ in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = Source(
            space: space,
            apollo: apollo,
            operations: operations
        )

        let item = space.newItem()
        item.itemID = "test-item-id"
        item.isFavorite = true
        try space.save()

        source.unfavorite(item: item)
        XCTAssertFalse(item.isFavorite)

        waitForExpectations(timeout: 1)
    }
}
