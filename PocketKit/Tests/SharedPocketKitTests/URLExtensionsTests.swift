// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import SharedPocketKit

class URLExtensionsTests: XCTestCase {
    func test_withoutPercentEncoding_isValidURL_returnsURL() {
        let source = "https://example.com/foo bar"
        let url = URL(percentEncoding: source)
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "https://example.com/foo%20bar")
    }

    func test_withoutPercentEncoding_isInvalidURL_addsPercentEncodingAndReturnsURL() {
        let source = "https://example.com/foo bar"
        let url = URL(percentEncoding: source)
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "https://example.com/foo%20bar")
    }

    func test_withPercentEncoding_isValidURL_returnsURL() {
        let source = "https://example.com/foo%20bar"
        let url = URL(percentEncoding: source)
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "https://example.com/foo%20bar")
    }

    func test_withPercentEncoding_isInvalidURL_returnsURL() {
        let source = "https://example.com/foo%20bar https://example.com/biz%20baz"
        let url = URL(percentEncoding: source)
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.absoluteString, "https://example.com/foo%20bar%20https://example.com/biz%20baz")
    }

    func test_isInvalidURL_returnsNil() {
        let source = ""
        let url = URL(percentEncoding: source)
        XCTAssertNil(url)
    }
}
