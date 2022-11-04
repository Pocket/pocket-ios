import XCTest
import CoreData
@testable import PocketKit
import Combine
import SharedPocketKit
@testable import Sync

class MockBadgeProvider: BadgeProvider {
    var applicationIconBadgeNumber: Int = 0
}

final class AppBadgeTrackerTests: XCTestCase {
    private var space: Space!
    private var source: MockSource!
    private var userDefaults: UserDefaults!
    private var accountViewModel: AccountViewModel!
    private var badgeProvider: MockBadgeProvider!
    private var savedItem: NSManagedObject!
    private var archivedItem: NSManagedObject!

    override func setUp() {
        space = .testSpace()
        source = MockSource()
        source.mainContext = space.context
        savedItem = space.buildSavedItem()
        archivedItem = space.buildSavedItem(isArchived: true)

        userDefaults = UserDefaults()
        badgeProvider = MockBadgeProvider()
    }

    private func subject(completion: (() -> Void)? = nil) -> AppBadgeSetup {
        return AppBadgeSetup(source: source, userDefaults: userDefaults, badgeProvider: badgeProvider, completion: completion)
    }

    override func tearDown() {
        userDefaults.removeObject(forKey: AccountViewModel.ToggleAppBadgeKey)
    }

    func test_on_savedItemsUpdated_noSubscriberCalled() {
        userDefaults.setValue(false, forKey: AccountViewModel.ToggleAppBadgeKey)

        source.mainContext.insert(savedItem)

        NotificationCenter.default.post(name: .listUpdated, object: nil)

        XCTAssertEqual(badgeProvider.applicationIconBadgeNumber, 0)
        source.mainContext.delete(savedItem)
    }

    func test_on_savedItemsUpdated_subscribersCalledAddingElement() {
        let badgeExpectation = expectation(description: "expected badge count to be updated")
        let subject = subject {
            badgeExpectation.fulfill()
        }
        badgeExpectation.assertForOverFulfill = false

        userDefaults.setValue(true, forKey: AccountViewModel.ToggleAppBadgeKey)

        source.mainContext.insert(savedItem)
        source.mainContext.insert(archivedItem)

        NotificationCenter.default.post(name: .listUpdated, object: nil)

        wait(for: [badgeExpectation], timeout: 1)
        XCTAssertEqual(badgeProvider.applicationIconBadgeNumber, 1)
        source.mainContext.delete(savedItem)
        source.mainContext.delete(archivedItem)
    }

    func test_on_savedItemsUpdated_subscribersCalledAddingAndDeleting() {
        let badgeExpectation = expectation(description: "expected badge count to be updated")
        let subject = subject {
            badgeExpectation.fulfill()
        }
        badgeExpectation.assertForOverFulfill = false

        userDefaults.setValue(true, forKey: AccountViewModel.ToggleAppBadgeKey)

        source.mainContext.insert(savedItem)

        source.mainContext.delete(savedItem)
        NotificationCenter.default.post(name: .listUpdated, object: nil)

        wait(for: [badgeExpectation], timeout: 1)
        XCTAssertEqual(badgeProvider.applicationIconBadgeNumber, 0)
    }
}
