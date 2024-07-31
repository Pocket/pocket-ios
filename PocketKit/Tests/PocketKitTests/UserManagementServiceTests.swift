// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import SharedPocketKit
@testable import PocketKit

class UserManagementServiceTests: XCTestCase {
    var subscriptions: Set<AnyCancellable>!
    var appSession: AppSession!
    var user: MockUser!
    var notificationCenter: NotificationCenter!
    var source: MockSource!
    var service: UserManagementService!

    override func setUp() {
        super.setUp()

        subscriptions = []

        appSession = AppSession(keychain: MockKeychain(), groupID: "pocket")
        user = MockUser()
        notificationCenter = .default
        source = MockSource()
        service = UserManagementService(
            appSession: appSession,
            user: user,
            notificationCenter: notificationCenter,
            source: source
        )
    }

    func test_unauthorizedResponse_logsOutUser() {
        let clearExpectation = expectation(description: "user was cleared")
        user.stubClear {
            clearExpectation.fulfill()
        }

        notificationCenter.post(name: .unauthorizedResponse, object: nil)

        wait(for: [clearExpectation])

        XCTAssertNil(appSession.currentSession)
    }
}
