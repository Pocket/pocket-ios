// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class LocalSavesSearchTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var user: MockUser!
    private var space: Space!

    override func setUp() {
        super.setUp()
        source = MockSource()
        user = MockUser()
        space = .testSpace()
    }

    override func tearDownWithError() throws {
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(source: Source? = nil) -> LocalSavesSearch {
        LocalSavesSearch(source: source ?? self.source)
    }

    func test_search_showsResultsAndCaches() throws {
        try setupLocalSavesSearch()
        let sut = subject()
        let results = sut.search(with: "saved")
        XCTAssertEqual(results.count, 2)
    }

    private func setupLocalSavesSearch() throws {
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                url: "http://example.com/item-1-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "saved-item-\($0)")
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }
    }
}
