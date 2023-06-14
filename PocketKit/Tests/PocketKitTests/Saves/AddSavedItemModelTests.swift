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
        let goodURLs: [String] = ["www.mozilla.com", "mozilla.co.uk", "https://mozilla.ca", "http://www.mozilla.co.jp"]
        let badURLs: [String] = ["not a real URL", "www. almost a real url .com", "fdsa$%#Q$%#fds%$#@FDs543"]
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
}
