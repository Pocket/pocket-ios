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
    var accessService: PocketAccessService!
    private var mockAuthenticationSession: MockAuthenticationSession!

    @MainActor
    override func setUp() {
        super.setUp()

        subscriptions = []

        appSession = AppSession(keychain: MockKeychain(), groupID: "pocket")
        mockAuthenticationSession = MockAuthenticationSession()
                mockAuthenticationSession.stubStart {
                    self.mockAuthenticationSession.completionHandler?(
                        self.mockAuthenticationSession.url,
                        self.mockAuthenticationSession.error
                    )
                    return true
                }

                let authClient = AuthorizationClient(consumerKey: "the-consumer-key", adjustSignupEventToken: "token", tracker: MockTracker()) { (_, _, completion) in
                    self.mockAuthenticationSession.completionHandler = completion
                    return self.mockAuthenticationSession
                }
        accessService = PocketAccessService(
            authorizationClient: authClient,
            appSession: appSession,
            tracker: MockTracker(),
            client: MockV3Client()
        )
        user = MockUser()
        notificationCenter = .default
        source = MockSource()
        service = UserManagementService(
            accessService: accessService,
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
    }
}
