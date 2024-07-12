// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync

@testable import PocketKit

class CollectionUrlFormatterTests: XCTestCase {
    static let correctUrlString = "https://getpocket.com/collections/slug-1"
    static let wrongUrlStrings = [
        "https://getpocket.com/hooray/slug-1",
        "https://getpocket.com/collection/slug-1",
        "ciao",
        "I am Groot",
        "https://getpucket.com/collections/slug-1",
        "https://example.com/collections/slug-1"
    ]

    private static func pickAWrongString() -> String {
        let index = Int.random(in: 0..<Self.wrongUrlStrings.count)
        return Self.wrongUrlStrings[index]
    }

    func testCorrectUrlStringIsRecognized() {
        XCTAssertTrue(CollectionUrlFormatter.isCollectionUrl(Self.correctUrlString))
    }

    func testCorrectUrlStringReturnsSlug() {
        let slug = CollectionUrlFormatter.slug(from: Self.correctUrlString)
        XCTAssertNotNil(slug)
        XCTAssertEqual(slug, "slug-1")
    }

    func testWrongUrlStringIsRecognized() {
        XCTAssertFalse(CollectionUrlFormatter.isCollectionUrl(Self.pickAWrongString()))
    }

    func testWrongUrlStringReturnsNilSlug() {
        XCTAssertNil(CollectionUrlFormatter.slug(from: Self.pickAWrongString()))
    }
}
