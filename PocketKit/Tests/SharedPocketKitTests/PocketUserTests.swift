// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import SharedPocketKit

class PocketUserTests: XCTestCase {
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "PocketUserTests")
    }

    override func tearDown() {
        userDefaults.resetKeys()
        super.tearDown()
    }

    func subject(
        userDefaults: UserDefaults? = nil
    ) -> PocketUser {
        return PocketUser(
            userDefaults: userDefaults ?? self.userDefaults
        )
    }

    func test_setStatus_withPremiumTrue_setsPremiumStatus() {
        let user = subject()
        user.setPremiumStatus(true)
        XCTAssertEqual(user.status, .premium)
    }

    func test_setStatus_withPremiumFalse_setsFreeStatus() {
        let user = subject()
        user.setPremiumStatus(false)
        XCTAssertEqual(user.status, .free)
    }

    func test_clear_setsLoggedOutStatus() {
        let user = subject()
        user.clear()
        XCTAssertEqual(user.status, .unknown)
    }
}
