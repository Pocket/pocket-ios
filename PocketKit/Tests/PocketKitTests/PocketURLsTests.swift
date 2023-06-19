// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import SharedPocketKit
@testable import PocketKit

final class PocketURLsTests: XCTestCase {
    func test_pocketPremiumURL_whenURLIsNil_returnsNil() {
        let user = MockUser(status: .free)
        let premiumURL = pocketPremiumURL(nil, user: user)
        XCTAssertNil(premiumURL)
    }

    func test_pocketPremiumURL_forFreeUser_returnsOriginalURL() {
        let user = MockUser(status: .free)
        let url = URL(string: "https://getpocket.com/example")!
        let premiumURL = pocketPremiumURL(url, user: user)
        XCTAssertEqual(url, premiumURL)
    }

    func test_pocketPremiumURL_forPremiumUser_nonPocketURL_returnsOriginalURL() {
        let user = MockUser(status: .premium)
        let url = URL(string: "https://example.com/example")!
        let premiumURL = pocketPremiumURL(url, user: user)
        XCTAssertEqual(url, premiumURL)
    }

    func test_pocketPremiumURL_forPremiumUser_PocketURL_returnsPremiumURL() {
        let user = MockUser(status: .premium)
        let url = URL(string: "https://getpocket.com/example")!
        let expectedURL = URL(string: "https://getpocket.com/example?premium_user=true")
        let premiumURL = pocketPremiumURL(url, user: user)
        XCTAssertEqual(premiumURL, expectedURL)
    }

    func test_pocketShareURL_whenURLIsNil_returnsNil() {
        let shareURL = pocketShareURL(nil, source: "")
        XCTAssertNil(shareURL)
    }

    func test_pocketShareURL_whenURLDoesNotContainUTMSource_returnsUpdatedURL() {
        let shareURL = pocketShareURL(URL(string: "https://getpocket.com/example")!, source: "tests")!
        let queryItems = URLComponents(url: shareURL, resolvingAgainstBaseURL: false)!.queryItems
        let source = queryItems!.first(where: { $0.name == "utm_source" })!
        XCTAssertEqual(source.value, "tests")
    }

    func test_pocketShareURL_whenURLContainsUTMSource_replacesSource() {
        let shareURL = pocketShareURL(URL(string: "https://getpocket.com/example?utm_source=foo")!, source: "tests")!
        let queryItems = URLComponents(url: shareURL, resolvingAgainstBaseURL: false)!.queryItems
        let source = queryItems!.first(where: { $0.name == "utm_source" })!
        XCTAssertEqual(source.value, "tests")
    }
}
