// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import SharedPocketKit

class RecentTagProviderTests: XCTestCase {
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "PocketUserTests")
    }

    override func tearDown() {
        // Is this better than removing the suite?
        userDefaults.resetKeys()
        super.tearDown()
    }

    func subject(
        userDefaults: UserDefaults? = nil
    ) -> RecentTagsProvider {
        return RecentTagsProvider(
            userDefaults: userDefaults ?? self.userDefaults,
            key: UserDefaults.Key.recentTags
        )
    }

    func test_initial_recentTags() throws {
        let recentTagsProvider = subject()
        XCTAssertEqual(recentTagsProvider.recentTags, [])
    }

    func test_getInitialRecentTags_withEmptyTags_hasNoRecentTags() throws {
        let recentTagsProvider = subject()
        recentTagsProvider.getInitialRecentTags(with: [])
        XCTAssertEqual(recentTagsProvider.recentTags, [])
    }

    func test_recentTags_showsValidArray() {
        userDefaults.setValue(["tag 0", "tag 1", "tag 2"], forKey: UserDefaults.Key.recentTags)
        let recentTagsProvider = subject()
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 0", "tag 1", "tag 2"])
    }

    func test_getInitialRecentTags_withEmptyUserDefaults_showsValidArray() {
        let recentTagsProvider = subject()
        recentTagsProvider.getInitialRecentTags(with: ["tag 0", "tag 1", "tag 2", "tag 3"])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 0", "tag 1", "tag 2"])
    }

    func test_getInitialRecentTags_withFullUserDefaults_showsValidArray() {
        userDefaults.setValue(["tag 0", "tag 1", "tag 2"], forKey: UserDefaults.Key.recentTags)
        let recentTagsProvider = subject()
        recentTagsProvider.getInitialRecentTags(with: ["tag 3", "tag 4", "tag 5"])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 0", "tag 1", "tag 2"])
    }

    func test_updateRecentTags_withEmptyTags_hasNoRecentTags() {
        let recentTagsProvider = subject()
        recentTagsProvider.updateRecentTags(with: [], and: [])
        XCTAssertEqual(recentTagsProvider.recentTags, [])
    }
    func test_updateRecentTags_withNoOriginalTags_andNewInputTag_showsValidArray() {
        let recentTagsProvider = subject()
        recentTagsProvider.updateRecentTags(with: [], and: ["tag 3"])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 3"])
    }

    func test_updateRecentTags_withOriginalTags_andNewInputTag_showsValidArray() {
        userDefaults.setValue(["tag 1", "tag 2", "tag 3"], forKey: UserDefaults.Key.recentTags)
        let recentTagsProvider = subject()
        recentTagsProvider.updateRecentTags(with: ["tag 0", "tag 1", "tag 2", "tag 3"], and: ["tag 0", "tag 4"])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 2", "tag 3", "tag 4"])
    }

    func test_updateRecentTags_withExistingInputTag_doesNotUpdateUserDefaults() {
        userDefaults.setValue(["tag 1", "tag 2", "tag 3"], forKey: UserDefaults.Key.recentTags)
        let recentTagsProvider = subject()
        recentTagsProvider.updateRecentTags(with: ["tag 0", "tag 1", "tag 2", "tag 3"], and: ["tag 2"])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 1", "tag 2", "tag 3"])
    }

    func test_updateRecentTags_withEmptyInputTags_doesNotUpdateArray() {
        userDefaults.setValue(["tag 0", "tag 1", "tag 2"], forKey: UserDefaults.Key.recentTags)
        let recentTagsProvider = subject()
        recentTagsProvider.updateRecentTags(with: ["tag 0", "tag 1", "tag 2", "tag 3", "tag 4", "tag 5"], and: [])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 0", "tag 1", "tag 2"])
    }

    func test_updateRecentTags_withInputTags_alreadyInRecentTags_doesNotUpdateUserDefaults() {
        userDefaults.setValue(["tag 0", "tag 1", "tag 2"], forKey: UserDefaults.Key.recentTags)
        let recentTagsProvider = subject()
        recentTagsProvider.updateRecentTags(with: ["tag 1", "tag 2", "tag 3", "tag 4"], and: ["tag 0"])
        XCTAssertEqual(recentTagsProvider.recentTags, ["tag 0", "tag 1", "tag 2"])
    }
}
