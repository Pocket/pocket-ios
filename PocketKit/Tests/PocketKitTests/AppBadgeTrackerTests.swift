// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import CoreData
@testable import PocketKit
import Combine
import SharedPocketKit
@testable import Sync

// swiftlint:disable force_try
class MockBadgeProvider: BadgeProvider {
    var applicationIconBadgeNumber: Int = 0
}

final class AppBadgeTrackerTests: XCTestCase {
    private var space: Space!
    private var source: MockSource!
    private var userDefaults: UserDefaults!
    private var accountViewModel: AccountViewModel!
    private var badgeProvider: MockBadgeProvider!

    override func setUp() {
        super.setUp()
        space = .testSpace()
        source = MockSource()
        source.viewContext = space.viewContext

        userDefaults = UserDefaults()
        badgeProvider = MockBadgeProvider()

        source.stubUnreadSaves {
            try! self.space.fetchSavedItems().count
        }
    }

    private func subject(completion: (() -> Void)? = nil) -> AppBadgeSetup {
        return AppBadgeSetup(source: source, userDefaults: userDefaults, badgeProvider: badgeProvider, completion: completion)
    }

    override func tearDownWithError() throws {
        userDefaults.removeObject(forKey: AccountViewModel.ToggleAppBadgeKey)
        try space.clear()
        try space.save()
        try super.tearDownWithError()
    }

    func test_on_savedItemsUpdated_noSubscriberCalled() throws {
        userDefaults.setValue(false, forKey: AccountViewModel.ToggleAppBadgeKey)
        space.buildSavedItem()
        try space.save()

        NotificationCenter.default.post(name: .listUpdated, object: nil)

        XCTAssertEqual(badgeProvider.applicationIconBadgeNumber, 0)
    }

    func test_on_savedItemsUpdated_subscribersCalledAddingElement() throws {
        let badgeExpectation = expectation(description: "expected badge count to be updated")
        let subject = subject {
            badgeExpectation.fulfill()
        }
        badgeExpectation.assertForOverFulfill = false

        userDefaults.setValue(true, forKey: AccountViewModel.ToggleAppBadgeKey)

        space.buildSavedItem(item: try space.createItem())
        space.buildSavedItem(remoteID: "saved-item-2", url: "http://example.com/item-2", isArchived: true, item: try space.createItem(remoteID: "item-2", givenURL: "http://example.com/item-2"))
        try space.save()

        NotificationCenter.default.post(name: .listUpdated, object: nil)

        wait(for: [badgeExpectation], timeout: 2)
        XCTAssertEqual(badgeProvider.applicationIconBadgeNumber, 1)
    }

    func test_on_savedItemsUpdated_subscribersCalledAddingAndDeleting() throws {
        let badgeExpectation = expectation(description: "expected badge count to be updated")
        let subject = subject {
            badgeExpectation.fulfill()
        }
        badgeExpectation.assertForOverFulfill = false

        userDefaults.setValue(true, forKey: AccountViewModel.ToggleAppBadgeKey)

        let savedItem = space.buildSavedItem()
        try space.save()
        space.delete(savedItem)
        try space.save()

        NotificationCenter.default.post(name: .listUpdated, object: nil)

        wait(for: [badgeExpectation], timeout: 2)
        XCTAssertEqual(badgeProvider.applicationIconBadgeNumber, 0)
    }
}
// swiftlint:enable force_try
