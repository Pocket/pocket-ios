// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync
import Combine

@testable import PocketKit
@testable import SharedPocketKit

class HomeRefreshCoordinatorTests: XCTestCase {
    private var notificationCenter: NotificationCenter!
    private var lastRefresh: LastRefresh!
    private var source: MockSource!
    private var subscriptions: Set<AnyCancellable>!
    private var appSession: AppSession!
    private var taskScheduler: MockBGTaskScheduler!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        notificationCenter = NotificationCenter()
        userDefaults = UserDefaults()
        lastRefresh = UserDefaultsLastRefresh(defaults: userDefaults)
        lastRefresh.reset()
        source = MockSource()
        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        appSession.currentSession = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        taskScheduler = MockBGTaskScheduler()
        taskScheduler.stubRegisterHandler { _, _, _ in
            return true
        }
        taskScheduler.stubCancel { _ in }
        taskScheduler.stubSubmit { _ in }
        subscriptions = []
    }

    func subject(
        notificationCenter: NotificationCenter? = nil,
        lastRefresh: LastRefresh? = nil,
        taskScheduler: BGTaskSchedulerProtocol? = nil,
        source: Source? = nil,
        appSession: AppSession? = nil
    ) -> HomeRefreshCoordinator {
        return HomeRefreshCoordinator(
            notificationCenter: notificationCenter ?? self.notificationCenter,
            taskScheduler: taskScheduler ?? self.taskScheduler,
            appSession: appSession ?? self.appSession,
            source: source ?? self.source,
            lastRefresh: lastRefresh ?? self.lastRefresh
        )
    }

    func test_firstRefresh_setsUserDefaults() {
        XCTAssertNil(lastRefresh.lastRefreshHome)
        source.stubFetchSlateLineup { _ in }

        let expectRefresh = expectation(description: "Refresh home")

        let coordinator = subject()

        coordinator.refresh {
            expectRefresh.fulfill()
        }
        wait(for: [expectRefresh], timeout: 10)
        XCTAssertNotNil(lastRefresh.lastRefreshHome)
    }

    func test_coordinator_whenDataIsNotStale_doesNotRefreshHome() {
        lastRefresh.refreshedHome()
        XCTAssertNotNil(lastRefresh.lastRefreshHome)
        source.stubFetchSlateLineup { _ in
            XCTFail("Should not have refreshed")
        }

        let coordinator = subject()
        let refreshExpectation = expectation(description: "did finish refreshing")
        coordinator.refresh(isForced: false) {
            refreshExpectation.fulfill()
        }
        wait(for: [refreshExpectation], timeout: 5)
    }

    func test_coordinator_whenDataIsStale_refreshesHome() {
        let date = Calendar.current.date(byAdding: .hour, value: -12, to: Date())
        userDefaults.setValue(date!.timeIntervalSince1970, forKey: UserDefaultsLastRefresh.lastRefreshedHomeAtKey)
        XCTAssertNotNil(lastRefresh.lastRefreshHome)
        source.stubFetchSlateLineup { _ in }

        let coordinator = subject()

        let expectRefresh = expectation(description: "Refresh home")
        coordinator.refresh {
            expectRefresh.fulfill()
        }
        wait(for: [expectRefresh], timeout: 10)
        XCTAssertNotEqual(lastRefresh.lastRefreshHome, date!.timeIntervalSince1970)
    }

    func test_coordinator_whenForceRefresh_refreshesHome() {
        lastRefresh.refreshedHome()
        XCTAssertNotNil(lastRefresh.lastRefreshHome)
        source.stubFetchSlateLineup { _ in }

        let expectRefresh = expectation(description: "Refresh home")

        let coordinator = subject()

        coordinator.refresh(isForced: true) {
            expectRefresh.fulfill()
        }
        wait(for: [expectRefresh], timeout: 10)
    }

    func test_refresh_delegatesToSource() {
        let fetchExpectation = expectation(description: "expected to fetch slate lineup")
        source.stubFetchSlateLineup { _ in fetchExpectation.fulfill() }

        let coordinator = subject()

        coordinator.refresh(isForced: true) { }

        wait(for: [fetchExpectation], timeout: 10)
        XCTAssertNotNil(source.fetchSlateLineupCall(at: 0))
    }
// TODO: Renable once we fix our singleton use in tests
//    func test_coordinator_whenEnterForeground_whenDataIsNotStale_doesNotRefreshHome() {
//        source.stubFetchSlateLineup { _ in
//            XCTFail("Should not fetch slate lineup")
//        }
//        lastRefresh.refreshedHome()
//
//        var coordinator: RefreshCoordinator? = subject()
//        coordinator!.initialize()
//        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: nil)
//        _ = XCTWaiter.wait(for: [expectation(description: "Ensure notification posts")], timeout: 5.0)
//        coordinator = nil
//    }
//
//    func test_coordinator_whenEnterForeground_whenDataIsStale_refreshesHome() {
//        let fetchExpectationInit = expectation(description: "initid fetch slate lineup")
//        fetchExpectationInit.assertForOverFulfill = true
//        let fetchExpectation = expectation(description: "expected to fetch slate lineup")
//
//        source.stubFetchSlateLineup { _ in fetchExpectationInit.fulfill() }
//        var coordinator: RefreshCoordinator? = subject()
//        coordinator!.initialize()
//        wait(for: [fetchExpectationInit], timeout: 10)
//
//        let date = Calendar.current.date(byAdding: .hour, value: -12, to: Date())
//        userDefaults.setValue(date!.timeIntervalSince1970, forKey: UserDefaultsLastRefresh.lastRefreshedHomeAtKey)
//        source.stubFetchSlateLineup { _ in fetchExpectation.fulfill() }
//
//        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: nil)
//
//        wait(for: [fetchExpectation], timeout: 10)
//        XCTAssertEqual(source.fetchSlateLineupCall(at: 0)?.identifier, "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1")
//        coordinator = nil
//    }
//
//    func test_coordinator_whenNoSession_doesNotRefreshHome() {
//        source.stubFetchSlateLineup { _ in
//            XCTFail("Should not fetch slate lineup")
//        }
//        lastRefresh.reset()
//        XCTAssertNil(lastRefresh.lastRefreshHome)
//
//        var coordinator: RefreshCoordinator? = subject(appSession: AppSession(groupID: "group"))
//        coordinator!.initialize()
//        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: nil)
//        _ = XCTWaiter.wait(for: [expectation(description: "Ensure notification posts")], timeout: 5.0)
//
//        XCTAssertNil(lastRefresh.lastRefreshHome)
//        coordinator = nil
//    }
}
