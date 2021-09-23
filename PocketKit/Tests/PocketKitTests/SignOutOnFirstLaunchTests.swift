// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit

class SignOutOnFirstLaunchTests: XCTestCase {
    var accessTokenStore: MockAccessTokenStore!
    var signOut: SignOutOnFirstLaunch!
    var defaults: UserDefaults!

    override func setUp() async throws {
        accessTokenStore = MockAccessTokenStore()
        defaults = UserDefaults()

        signOut = SignOutOnFirstLaunch(
            accessTokenStore: accessTokenStore,
            userDefaults: defaults
        )
    }

    func test_signOutOnFirstLaunch_whenRunOnFirstLaunch_clearsAccessToken() {
        defaults.set(false, forKey: SignOutOnFirstLaunch.hasAppBeenLaunchedPreviouslyKey)
        signOut.signOutOnFirstLaunch()

        XCTAssertEqual(accessTokenStore.deleteCalls.count, 1)
        XCTAssertTrue(defaults.bool(forKey: SignOutOnFirstLaunch.hasAppBeenLaunchedPreviouslyKey))
    }

    func test_signOutOnFirstLaunch_whenRunOnSubsequentLaunch_doesNotClearAccessToken() {
        defaults.set(true, forKey: SignOutOnFirstLaunch.hasAppBeenLaunchedPreviouslyKey)

        signOut.signOutOnFirstLaunch()
        XCTAssertEqual(accessTokenStore.deleteCalls.count, 0)
    }
}

class MockAccessTokenStore: AccessTokenStore {
    var accessToken: String? {
        fatalError("\(type(of: self)).\(#function) is not implemented")
    }

    var deleteCalls: [()] = []

    func delete() {
        deleteCalls.append(())
    }

    func save(token: String) {
        fatalError("\(type(of: self)).\(#function) is not implemented")
    }
}
