// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import PocketKit

class UrlValidatorTests: XCTestCase { 
    func testCorrectUrlReturnsItemUrl() {
        let validator = UrlValidator()
        let correctUrlString = "pocket:/app/openURL?url=https://example.com/this_is_an_article/"
        let correctUrl = URL(string: correctUrlString)
        XCTAssertNotNil(correctUrl)
        let itemUrl = validator.getItemUrl(from: correctUrl!)
        XCTAssertNotNil(itemUrl)
        XCTAssertEqual(itemUrl, "https://example.com/this_is_an_article/")
    }

    func testInvalidUrlReturnsNil() {
        let validator = UrlValidator()
        let invalidUrl = URL(string: "https://getpocket.com/hooray/not-an-article-from-widgets")
        XCTAssertNotNil(invalidUrl)
        let itemUrl = validator.getItemUrl(from: invalidUrl!)
        XCTAssertNil(itemUrl)
    }
}
