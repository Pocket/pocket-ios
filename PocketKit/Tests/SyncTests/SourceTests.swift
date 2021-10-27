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

    override func tearDownWithError() throws {
        try space.clear()
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
        let item = try space.seedSavedItem(remoteID: "test-item-id")
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
        let item = try space.seedSavedItem()
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
        let item = try space.seedSavedItem(remoteID: "delete-me")
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

    func test_archive_removesItemFromLocalStorage_andExecutesArchiveMutation() throws {
        let item = try space.seedSavedItem(remoteID: "archive-me")
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

    func test_saveRecommendation_createsPendingItem_andExecutesSaveItemOperation() throws {
        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubSaveItemOperation { (_, _, _ , _, _) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let recommendation = Slate.Recommendation(
            id: "recommendation-1",
            item: Slate.Item(
                id: "item-1",
                givenURL: URL(string: "https://given.example.com/item-1")!,
                resolvedURL: URL(string: "https://resolved.example.com/item-1")!,
                title: "Item 1",
                language: "en",
                topImageURL: URL(string: "https://example.com/item-1/top-image.png")!,
                timeToRead: 1,
                article: Article(
                    components: [.heading(HeadingComponent(content: "# Hello", level: 1))]
                ),
                excerpt: "This is the excerpt for Item 1",
                domain: "example.com",
                domainMetadata: Slate.DomainMetadata(
                    name: "Example",
                    logo: URL(string: "https://example.com/logo.png")!
                ),
                authors: [
                    Slate.Author(
                        id: "eb-white",
                        name: "E.B. White",
                        url: URL(string: "http://example.com/authors/eb-white")
                    )
                ],
                datePublished: Date()
            )
        )

        let source = subject()
        source.save(recommendation: recommendation)
        wait(for: [expectationToRunOperation], timeout: 1)

        let savedItems = try space.fetchSavedItems()
        XCTAssertEqual(savedItems.count, 1)

        let savedItem = savedItems[0]
        XCTAssertEqual(savedItem.url, URL(string: "https://resolved.example.com/item-1")!)

        let item = savedItem.item
        XCTAssertNotNil(item)
        XCTAssertEqual(item?.remoteID, recommendation.item.id)
        XCTAssertEqual(item?.givenURL, recommendation.item.givenURL)
        XCTAssertEqual(item?.resolvedURL, recommendation.item.resolvedURL)
        XCTAssertEqual(item?.title, recommendation.item.title)
        XCTAssertEqual(item?.language, recommendation.item.language)
        XCTAssertEqual(item?.topImageURL, recommendation.item.topImageURL)
        XCTAssertEqual(item.flatMap { Int($0.timeToRead) }, recommendation.item.timeToRead)
        XCTAssertEqual(item?.article, recommendation.item.article)
        XCTAssertEqual(item?.excerpt, recommendation.item.excerpt)
        XCTAssertEqual(item?.domain, recommendation.item.domain)
        XCTAssertEqual(item?.datePublished, recommendation.item.datePublished)

        let domainMeta = item?.domainMetadata
        XCTAssertEqual(domainMeta?.name, recommendation.item.domainMetadata?.name)
        XCTAssertEqual(domainMeta?.logo, recommendation.item.domainMetadata?.logo)

        let author = item?.authors?[0] as? Author
        XCTAssertEqual(author?.id, recommendation.item.authors![0].id)
        XCTAssertEqual(author?.name, recommendation.item.authors![0].name)
        XCTAssertEqual(author?.url, recommendation.item.authors![0].url)
    }

    func test_archiveRecommendation_archivesTheRespectiveItem() async throws {
        try space.seedSavedItem(
            remoteID: "saved-item-1",
            item: space.buildItem(
                remoteID: "item-1"
            )
        )

        let expectationToRunOperation = expectation(description: "Run operation")
        operations.stubItemMutationOperation { (_, _ , _: ArchiveItemMutation) in
            return BlockOperation {
                expectationToRunOperation.fulfill()
            }
        }

        let recommendation: Slate.Recommendation = .build(
            id: "recommendation-1",
            item: .build(id: "item-1")
        )

        let source = subject()
        source.archive(recommendation: recommendation)

        wait(for: [expectationToRunOperation], timeout: 1)

        try XCTAssertNil(space.fetchSavedItem(byRemoteID: "saved-item-1"))
    }

    func test_fetchSlates_returnsResultsFromSlateService() async throws {
        let slate = Slate(
            id: "my-slate",
            requestID: "request-id",
            experimentID: "experiment-id",
            name: "My Slate",
            description: "slate-description",
            recommendations: []
        )
        
        let expectedLineup = SlateLineup(
            id: "lineup-id",
            requestID: "lineup-request-id",
            experimentID: "experiment-id",
            slates: [slate]
        )
        
        slateService.stubFetchSlateLineup {
            expectedLineup
        }

        let actualLineup = try await subject().fetchSlateLineup("")

        XCTAssertEqual(actualLineup, expectedLineup)
    }

    func test_fetchSlate_returnsResultFromSlateService() async throws {
        let expectedSlate = Slate(
            id: "my-slate",
            requestID: "request-id",
            experimentID: "experiment-id",
            name: "My Slate",
            description: "slate-description",
            recommendations: []
        )
        
        slateService.stubFetchSlate { _ in
            return expectedSlate
        }

        let actualSlate = try await subject().fetchSlate("the-slate-id")

        XCTAssertEqual(actualSlate, expectedSlate)
    }
}
