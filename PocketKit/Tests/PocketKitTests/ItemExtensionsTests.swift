// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import PocketKit
@testable import Sync

class ItemExtensionsTests: XCTestCase {
    var space: Space!

    override func setUp() {
        super.setUp()
        space = .testSpace()
    }

    override func tearDownWithError() throws {
        try space.clear()
        try super.tearDownWithError()
    }

    func test_shouldOpenInWebView_andIsNotArticle_returnsTrue() throws {
        let savedItem: SavedItem = try space.createSavedItem()
        savedItem.item?.isArticle = false

        XCTAssertEqual(savedItem.shouldOpenInWebView(override: false), true)
    }

    func test_shouldOpenInWebView_andIsArticle_returnsFalse() throws {
        let savedItem: SavedItem = try space.createSavedItem()
        savedItem.item?.isArticle = true

        XCTAssertEqual(savedItem.shouldOpenInWebView(override: false), false)
    }

    func test_shouldOpenInWebView_withArticleComponents_returnsTrue() throws {
        let savedItem: SavedItem = try space.createSavedItem()
        savedItem.item?.article = .some(Article(components: [.text(TextComponent(content: "This article has components"))]))

        XCTAssertEqual(savedItem.item?.hasArticleComponents, true)
    }

    func test_hasArticleComponents_withEmptyArticleComponents_returnsFalse() throws {
        let savedItem: SavedItem = try space.createSavedItem()
        savedItem.item?.article = .some(Article(components: []))

        XCTAssertEqual(savedItem.item?.hasArticleComponents, false)
    }

    func test_hasArticleComponents_withNilArticleComponents_returnsFalse() throws {
        let savedItem: SavedItem = try space.createSavedItem()
        savedItem.item?.article = nil

        XCTAssertEqual(savedItem.item?.hasArticleComponents, false)
    }
}
