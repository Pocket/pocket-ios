// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import PocketGraph
import Combine
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class OnlineSearchTests: XCTestCase {
    private var source: MockSource!
    private var searchService: MockSearchService!

    override func setUp() {
        super.setUp()
        source = MockSource()
        searchService = MockSearchService()
        source.stubMakeSearchService { self.searchService }
    }

    override func tearDown() {
        source = nil
        searchService = nil
        super.tearDown()
    }

    func subject(source: Source? = nil, scope: SearchScope? = nil) -> OnlineSearch {
        return OnlineSearch(source: source ?? self.source, scope: scope ?? .saves)
    }

    func test_search_withSaves_showsResultsAndCaches() async {
        let sut = subject()

        let expectation = setupOnlineSearch(with: "search-term")
        sut.search(with: "search-term")
        await fulfillment(of: [expectation], timeout: 5.0)

        guard case .success(let items) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .saves)

        sut.search(with: "search-term")

        guard case .success(let items) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertNil(searchService.searchCall(at: 1))
    }

    func test_search_withArchive_showsResultsAndCaches() async {
        let sut = subject(scope: .archive)
        let expectation = setupOnlineSearch(with: "search-term")
        sut.search(with: "search-term")
        await fulfillment(of: [expectation], timeout: 5.0)

        guard case .success(let items) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .archive)

        sut.search(with: "search-term")
        guard case .success(let items) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertNil(searchService.searchCall(at: 1))
    }

    func test_search_withAll_showsResultsAndCaches() async {
        let sut = subject(scope: .all)
        let expectation = setupOnlineSearch(with: "search-term")
        sut.search(with: "search-term")
        await fulfillment(of: [expectation], timeout: 5.0)

        guard case .success(let items) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .all)

        sut.search(with: "search-term")
        guard case .success(let items) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertNil(searchService.searchCall(at: 1))
    }

    func test_hasCache_withPreviousSearchTerm_returnsTrue() async {
        let sut = subject()
        let term = "search-term"
        let expectation = setupOnlineSearch(with: "search-term")
        sut.search(with: term)
        await fulfillment(of: [expectation], timeout: 5.0)

        XCTAssertTrue(sut.hasCache(with: term))
    }

    func test_hasCache_withNewSearch_returnsFalse() {
        let sut = subject()
        let term = "search-term"
        XCTAssertFalse(sut.hasCache(with: term))
    }

    func test_hasCache_withLoadMoreResults_returnsNewResults() async {
        let sut = subject(scope: .archive)
        let expectation = setupOnlineSearch(with: "search-term")
        sut.search(with: "search-term")
        await fulfillment(of: [expectation], timeout: 5.0)

        guard case .success(let pageOneItems) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(pageOneItems.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .archive)

        let expectation2 = setupOnlineSearchPage2(with: "search-term")
        sut.search(with: "search-term", and: true)
        await fulfillment(of: [expectation2], timeout: 5.0)
        guard case .success(let pageTwoItems) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(pageTwoItems.count, 5)
        XCTAssertNotNil(searchService.searchCall(at: 1))
        XCTAssertNil(searchService.searchCall(at: 2))
    }

    // MARK: Error
    func test_search_whenFetchFails_throwsError() async {
        let sut = subject()
        let term = "search-term"
        let expectation = expectation(description: "online search")
        searchService.stubSearch { _, _ in
            expectation.fulfill()
            throw TestError.anError
        }
        sut.search(with: term)
        await fulfillment(of: [expectation], timeout: 5.0)

        guard case .failure(let error) = sut.results else {
            XCTFail("should not have failed")
            return
        }

        XCTAssertEqual(error as? TestError, .anError)
    }

    private func setupOnlineSearch(with term: String) -> XCTestExpectation {
        let itemParts = SavedItemParts(
            url: "http://localhost:8080/hello",
            remoteID: "saved-item-1",
            isArchived: false,
            isFavorite: false,
            _createdAt: 1,
            item: SavedItemParts.Item.AsItem(
                remoteID: "item-1",
                givenUrl: "http://localhost:8080/hello"
            ).asRootEntityType
        )

        let item = SearchSavedItem(remoteItem: itemParts)
        let expectation = expectation(description: "search called")
        searchService.stubSearch { _, _ in
            self.searchService._results = [item, item]
            expectation.fulfill()
        }
        return expectation
    }

    private func setupOnlineSearchPage2(with term: String) -> XCTestExpectation {
        let itemParts = SavedItemParts(
            url: "http://localhost:8080/hello",
            remoteID: "saved-item-1",
            isArchived: false,
            isFavorite: false,
            _createdAt: 1,
            item: SavedItemParts.Item.AsItem(
                remoteID: "item-1",
                givenUrl: "http://localhost:8080/hello"
            ).asRootEntityType
        )

        let item = SearchSavedItem(remoteItem: itemParts)
        let expectation = expectation(description: "search called")
        searchService.stubSearch { _, _ in
            self.searchService._results = [item, item, item]
            expectation.fulfill()
        }
        return expectation
    }
}
