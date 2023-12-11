// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit
import Combine
import Sync
import SharedPocketKit

final class InstantSyncTests: XCTestCase {
    private var source: MockSource!
    private var v3Client: MockV3Client!

    private var appSession: AppSession!
    private var session: SharedPocketKit.Session!
    private var instant: SharedPocketKit.Session!

    private var subject: InstantSync!

    override func setUp() {
        super.setUp()
        source = MockSource()
        appSession = AppSession(keychain: MockKeychain(), groupID: "test")
        session = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        appSession.currentSession = session
        v3Client = MockV3Client()

        subject = InstantSync(appSession: appSession, source: source, v3Client: v3Client)
    }

    func test_onRegister_didCallSubscribers() {
        let data = "data-to-register".data(using: .utf8)
        let registerExpectation = expectation(description: "register token called")
        v3Client.stubRegisterPushToken { _, pushType, token, session in
            XCTAssertEqual(pushType, .proddev)
            XCTAssertEqual(token, data!.base64EncodedString())
            XCTAssertEqual(session.guid, "test-guid")
            XCTAssertEqual(session.accessToken, "test-access-token")
            registerExpectation.fulfill()
            return nil
        }
        subject.register(deviceToken: data!)
        wait(for: [registerExpectation], timeout: 5)

        let blahdata = v3Client.registerPushTokenCall(at: 0)
        XCTAssertNotNil(blahdata)
    }

    func test_loggedOut_didCallSubscribers() {
        let deregisterExpectation = expectation(description: "deregister token called")
        v3Client.stubDeregisterPushToken { _, pushType, session in
            XCTAssertEqual(pushType, .proddev)
            XCTAssertEqual(session.guid, "test-guid")
            XCTAssertEqual(session.accessToken, "test-access-token")
            deregisterExpectation.fulfill()
            return nil
        }
        subject.loggedOut(session: appSession.currentSession)
        wait(for: [deregisterExpectation], timeout: 5)
        XCTAssertNotNil(v3Client.deregisterPushTokenCall(at: 0))
    }
}
