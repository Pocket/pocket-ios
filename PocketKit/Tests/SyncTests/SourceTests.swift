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
    var lastRefresh: MockLastRefresh!
    var tokenProvider: MockAccessTokenProvider!
    var slateService: MockSlateService!

    override func setUpWithError() throws {
        space = Space(container: .testContainer)
        apollo = MockApolloClient()
        operations = MockOperationFactory()
        lastRefresh = MockLastRefresh()
        tokenProvider = MockAccessTokenProvider()
        slateService = MockSlateService()

        lastRefresh.stubGetLastRefresh { nil}
    }

    func subject(
        space: Space? = nil,
        apollo: ApolloClientProtocol? = nil,
        operations: OperationFactory? = nil,
        lastRefresh: LastRefresh? = nil,
        tokenProvider: AccessTokenProvider? = nil,
        slateService: SlateService? = nil
    ) -> Source {
        Source(
            space: space ?? self.space,
            apollo: apollo ?? self.apollo,
            operations: operations ?? self.operations,
            lastRefresh: lastRefresh ?? self.lastRefresh,
            accessTokenProvider: tokenProvider ?? self.tokenProvider,
            slateService: slateService ?? self.slateService
        )
    }

    func test_refresh_addsFetchListOperationToQueue() {
        tokenProvider.accessToken = "test-token"
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubFetchList { _, _, _, _, _ in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()

        source.refresh()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(operations.fetchListCall(at: 0)?.token, "test-token")
    }

    func test_refreshWithCompletion_callsCompletionWhenFinished() {
        tokenProvider.accessToken = "test-token"
        operations.stubFetchList { _, _, _, _, _ in
            return BlockOperation { }
        }

        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        source.refresh {
            expectationToRunOperation.fulfill()
        }

        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_refresh_whenTokenIsNil_callsCompletion() {
        tokenProvider.accessToken = nil
        operations.stubFetchList { _, _, _, _, _ in
            return BlockOperation { }
        }

        let source = subject()

        let expectationToRunOperation = expectation(description: "Run operation")
        source.refresh {
            expectationToRunOperation.fulfill()
        }

        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_favorite_togglesIsFavorite_andExecutesFavoriteMutation() throws {
        let item = try space.seedItem(itemID: "test-item-id")
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: FavoriteItemMutation) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let source = subject()
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

        let source = subject()
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

        let source = subject()
        source.delete(item: item)

        let fetchedItem = try space.fetchSavedItem(byRemoteID: "delete-me")
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

        let source = subject()
        source.archive(item: item)

        let fetchedItem = try space.fetchSavedItem(byRemoteID: "archive-me")
        XCTAssertNil(fetchedItem)
        XCTAssertFalse(item.hasChanges)
        wait(for: [expectationToRunOperation], timeout: 1)
    }

    func test_fetchSlates_returnsResultsFromSlateService() async throws {
        let expectedSlates = [Slate(id: "my-slate", name: "My Slate", description: "My very awesome slate", recommendations: [])]
        slateService.stubFetchSlates {
            return expectedSlates
        }

        let actualSlates = try await subject().fetchSlates()

        XCTAssertEqual(actualSlates, expectedSlates)
    }

    func test_fetchSlate_returnsResultFromSlateService() async throws {
        let expectedSlate = Slate(id: "my-slate", name: "My Slate", description: "My very awesome slate", recommendations: [])
        slateService.stubFetchSlate { _ in
            return expectedSlate
        }

        let actualSlate = try await subject().fetchSlate("the-slate-id")

        XCTAssertEqual(actualSlate, expectedSlate)
    }
}
