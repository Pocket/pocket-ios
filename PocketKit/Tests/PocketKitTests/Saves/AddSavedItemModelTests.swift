// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit

final class AddSavedItemModelTests: XCTestCase {
    var source: MockSource!

    func subject() -> AddSavedItemModel {
        source = MockSource()
        return AddSavedItemModel(source: source, tracker: MockTracker())
    }

    func test_URLParsing() {
        let sut = subject()
        var saveCount: Int = 0

        source.stubSaveURL { _ in
            saveCount += 1
        }

        goodURLs.forEach {
            XCTAssertTrue(sut.saveURL($0))
        }

        XCTAssertTrue(saveCount == goodURLs.count)
        saveCount = 0

        badURLs.forEach {
            XCTAssertFalse(sut.saveURL($0))
        }

        XCTAssertTrue(saveCount == 0)
    }

    private var goodURLs: [String] {
        ["www.mozilla.com",
         "mozilla.co.uk",
         "https://mozilla.ca",
         "http://www.mozilla.co.jp",
         "https://getpocket.com/example?premium_user=true",
         "https://getpocket.com/example?utm_source=foo&otherParam=some%20Encoded%20String"]
    }

    private var badURLs: [String] {
        ["not a real URL",
         "www. almost a real url .com",
         "fdsa$%#Q$%#fds%$#@FDs543",
         "https://getpocket.com/example?utm_source=things started off pretty good!"]
    }
}
