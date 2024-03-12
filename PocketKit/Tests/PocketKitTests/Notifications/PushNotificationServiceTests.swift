// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit
import Combine
import Sync
import SharedPocketKit

final class PushNotificationServiceTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable>!
    private var source: MockSource!
    private var tracker: MockTracker!
    private var appSession: AppSession!
    private var instantSync: MockInstantSync!
    private var braze: MockPocketBraze!
    private var session: SharedPocketKit.Session!

    private var subject: PushNotificationService!

    override func setUp() {
        super.setUp()
        subscriptions = []
        source = MockSource()
        appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
        session = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        appSession.currentSession = session

        tracker = MockTracker()
        braze = MockPocketBraze()
        instantSync = MockInstantSync()

        // Stub here because log in is called at initilization
        instantSync.stubLoggedIn { _ in }
        braze.stubLoggedIn { _ in }
        instantSync.stubLoggedOut { _ in }
        braze.stubLoggedOut { _ in }
        subject = PushNotificationService(source: source, tracker: tracker, appSession: appSession, braze: braze, instantSync: instantSync)
    }

    override func tearDown() {
        super.tearDown()

        subscriptions = []
    }

    func test_onLogin_didCallSubscribers() {
        let sessionExpectation = expectation(description: "published error event")

        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { notification in
            guard let session = notification.object as? SharedPocketKit.Session  else {
                XCTFail("Session did not exist in notification center")
                return
            }
            XCTAssertEqual(session.guid, "test-guid")
            XCTAssertEqual(session.accessToken, "test-access-token")
            XCTAssertEqual(session.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        NotificationCenter.default.post(name: .userLoggedIn, object: session)

        wait(for: [sessionExpectation], timeout: 2)

        XCTAssertEqual(braze.loggedInCalls(), 2)
        XCTAssertEqual(instantSync.loggedInCalls(), 2)
    }

    func test_onLogout_callsSubscribersWithLogoutSession() {
        let sessionExpectation = expectation(description: "published error event")

        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { notification in
            guard let session = notification.object as? SharedPocketKit.Session  else {
                XCTFail("Session did not exist in notification center")
                return
            }
            XCTAssertEqual(session.guid, "logout-test-guid")
            XCTAssertEqual(session.accessToken, "logout-test-access-token")
            XCTAssertEqual(session.userIdentifier, "logout-test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        NotificationCenter.default.post(name: .userLoggedOut, object: SharedPocketKit.Session(guid: "logout-test-guid", accessToken: "logout-test-access-token", userIdentifier: "logout-test-id"))

        wait(for: [sessionExpectation])

        XCTAssertEqual(braze.loggedOutCalls(), 1)
        XCTAssertEqual(instantSync.loggedOutCalls(), 1)
    }
}
