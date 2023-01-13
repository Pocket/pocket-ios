// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync
import PocketGraph
import Combine
import SharedPocketKit

@testable import PocketKit

class OnlineSearchTests: XCTestCase {
    private var source: MockSource!
    private var searchService: MockSearchService!
    private var user: MockUser!
    private var subscriptions: [AnyCancellable] = []

    override func setUpWithError() throws {
        source = MockSource()
        searchService = MockSearchService()
        source.stubMakeSearchService { self.searchService }
    }

    func subject(source: Source? = nil, scope: SearchScope? = nil) -> OnlineSearch {
        return OnlineSearch(source: source ?? self.source, scope: scope ?? .saves)
    }

    func test_search_withSaves_showsResultsAndCaches() async {
        let sut = subject()
        sut.search(with: "search-term")
        await setupOnlineSearch(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .saves)

        searchService._results = []

        sut.search(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertNil(searchService.searchCall(at: 1))
    }

    func test_search_withArchive_showsResultsAndCaches() async {
        let sut = subject(scope: .archive)
        sut.search(with: "search-term")
        await setupOnlineSearch(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .archive)

        searchService._results = []

        sut.search(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertNil(searchService.searchCall(at: 1))
    }

    func test_search_withAll_showsResultsAndCaches() async {
        let sut = subject(scope: .all)
        sut.search(with: "search-term")
        await setupOnlineSearch(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .all)

        searchService._results = []

        sut.search(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertNil(searchService.searchCall(at: 1))
    }

    func test_clear_emptiesCaches() async {
        let sut = subject()
        sut.search(with: "search-term")
        await setupOnlineSearch(with: "search-term")
        XCTAssertEqual(sut.results?.count, 2)
        XCTAssertEqual(searchService.searchCall(at: 0)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 0)?.scope, .saves)

        sut.clear()
        sut.search(with: "search-term")

        await withCheckedContinuation { continuation in
            searchService.stubSearch { _, _ in
                self.searchService._results = []
                continuation.resume()
            }
        }

        XCTAssertEqual(sut.results?.count, 0)
        XCTAssertEqual(searchService.searchCall(at: 1)?.term, "search-term")
        XCTAssertEqual(searchService.searchCall(at: 1)?.scope, .saves)
    }

    private func setupOnlineSearch(with term: String) async {
        let item = SearchSavedItemParts(data: DataDict([
            "__typename": "SavedItem",
            "item": [
                "__typename": "Item",
                "title": term,
                "givenUrl": "http://localhost:8080/hello",
                "resolvedUrl": "http://localhost:8080/hello"
            ]
        ], variables: nil))

        await withCheckedContinuation { continuation in
            searchService.stubSearch { _, _ in
                self.searchService._results = [item, item]
                continuation.resume()
            }
        }
    }
}
