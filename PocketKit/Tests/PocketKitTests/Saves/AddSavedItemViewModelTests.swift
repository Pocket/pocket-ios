// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit

final class AddSavedItemViewModelTests: XCTestCase {
    var source: MockSource!

    func subject() -> AddSavedItemViewModel {
        source = MockSource()
        return AddSavedItemViewModel(source: source, tracker: MockTracker())
    }

    func test_URLParsing() async {
        let sut = subject()
        var saveCount: Int = 0

        source.stubSaveURL { _ in
            saveCount += 1
        }

        for url in goodURLs {
            let isValid = await sut.saveURL(url)
            XCTAssertTrue(isValid)
        }

        XCTAssertTrue(saveCount == goodURLs.count)
        saveCount = 0

        for url in badURLs {
            let isValid = await sut.saveURL(url)
            XCTAssertFalse(isValid)
        }

        XCTAssertTrue(saveCount == 0)
    }

    private var goodURLs: [String] {
        [
            "https://mozilla.ca",
            "http://www.mozilla.co.jp",
            "https://getpocket.com/example?premium_user=true",
            "this is a valid site: https://example.com"
        ]
    }

    private var badURLs: [String] {
        [
            "www.mozilla.com",
            "mozilla.co.uk",
            "not a real URL",
            "www. almost a real url .com",
            "fdsa$%#Q$%#fds%$#@FDs543",
        ]
    }
}
