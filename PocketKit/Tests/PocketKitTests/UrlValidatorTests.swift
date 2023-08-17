// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import PocketKit

class UrlValidatorTests: XCTestCase {
    static let validUrlNotFromWidgets = [
        "https://getpocket.com/hooray/not-an-article-from-widgets",
        "https://getpocket.com/are-you-there/no-i-am-not",
        "https://getpucket.com/collections/this-may-be-a-collection",
        "https://example.com/this-is-an-article"
    ]

    func testCorrectUrlReturnsItemUrl() {
        let validator = UrlValidator()
        let correctUrlString = "pocket:/app/openURL?url=https://example.com/this_is_an_article/"
        let correctUrl = URL(string: correctUrlString)
        XCTAssertNotNil(correctUrl)
        let itemUrl = validator.getItemUrl(from: correctUrl!)
        XCTAssertNotNil(itemUrl)
        XCTAssertEqual(itemUrl, "https://example.com/this_is_an_article/")
    }

    func testWrongUrlReturnsNil() {
        let validator = UrlValidator()
        let index = Int.random(in: 0..<Self.validUrlNotFromWidgets.count)
        let wrongtUrlString = Self.validUrlNotFromWidgets[index]
        let wrongUrl = URL(string: wrongtUrlString)
        XCTAssertNotNil(wrongUrl)
        let itemUrl = validator.getItemUrl(from: wrongUrl!)
        XCTAssertNil(itemUrl)
    }
}
