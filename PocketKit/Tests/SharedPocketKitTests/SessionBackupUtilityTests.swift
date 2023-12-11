// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import SharedPocketKit

// swiftlint:disable force_try
class SessionBackupUtilityTests: XCTestCase {
    var userDefaults: UserDefaults!
    var store: MockEncryptedStore!
    var notificationCenter: NotificationCenter!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "SessionBackupUtilityTests")!
        userDefaults.removePersistentDomain(forName: "SessionBackupUtilityTests")

        store = MockEncryptedStore()
        notificationCenter = .default
    }

    func test_password_ifNil_createdNewPassword() {
        store.stubEncrypt { _, _ in }
        store.stubDecryptStore { _ in return nil }

        func createUtility() -> SessionBackupUtility {
            return SessionBackupUtility(
                userDefaults: userDefaults,
                store: store,
                notificationCenter: notificationCenter
            )
        }

        // Passwords are fetched or created on init, but the utility itself is unnecessary
        _ = createUtility()

        let password = userDefaults.string(forKey: LegacyUserMigration.decryptionKey)
        XCTAssertNotNil(password)
    }

    func test_password_persistsAcrossUtilities() {
        userDefaults.set("password", forKey: LegacyUserMigration.decryptionKey)

        store.stubEncrypt { _, _ in }
        store.stubDecryptStore { _ in return nil }

        func createUtility() -> SessionBackupUtility {
            return SessionBackupUtility(
                userDefaults: userDefaults,
                store: store,
                notificationCenter: notificationCenter
            )
        }

        // Passwords are fetched or created on init, but the utility itself is unnecessary
        _ = createUtility()
        let firstPassword = userDefaults.string(forKey: LegacyUserMigration.decryptionKey)
        XCTAssertEqual(firstPassword!, "password")

        // Passwords are fetched or created on init, but the utility itself is unnecessary
        _ = createUtility()
        let secondPassword = userDefaults.string(forKey: LegacyUserMigration.decryptionKey)
        XCTAssertEqual(secondPassword!, "password")
    }

    func test_userLoggedIn_withNoExistingData_savesSessionData() {
        let session = Session(guid: "test-guid", accessToken: "test-accessToken", userIdentifier: "test-uid")

        store.stubDecryptStore { _ in
            return Data()
        }

        let encryptExpectation = expectation(description: "expected encrypt to be called")
        store.stubEncrypt { data, _ in
            defer { encryptExpectation.fulfill() }

            let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
            XCTAssertEqual(json["guid"] as! String, session.guid)
            XCTAssertEqual(json["accessToken"] as! String, session.accessToken)
            XCTAssertEqual(json["uid"] as! String, session.userIdentifier)
        }

        let utility = SessionBackupUtility(
            userDefaults: userDefaults,
            store: store,
            notificationCenter: notificationCenter
        )
        utility.start()

        notificationCenter.post(name: .userLoggedIn, object: session)

        wait(for: [encryptExpectation], timeout: 1)
    }

    func test_userLoggedIn_withExistingData_overwritesSessionData() {
        let session = Session(guid: "test-guid", accessToken: "test-accessToken", userIdentifier: "test-uid")

        let store = MockEncryptedStore()

        store.stubDecryptStore { _ in
            let data: [String: Any] = ["guid": "guid", "accessToken": "accessToken", "uid": "uid"]
            let json = try! JSONSerialization.data(withJSONObject: data)
            return json
        }

        let encryptExpectation = expectation(description: "expected encrypt to be called")
        store.stubEncrypt { data, _ in
            defer { encryptExpectation.fulfill() }

            let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
            XCTAssertEqual(json["guid"] as! String, session.guid)
            XCTAssertEqual(json["accessToken"] as! String, session.accessToken)
            XCTAssertEqual(json["uid"] as! String, session.userIdentifier)
        }

        let utility = SessionBackupUtility(
            userDefaults: userDefaults,
            store: store,
            notificationCenter: notificationCenter
        )
        utility.start()

        notificationCenter.post(name: .userLoggedIn, object: session)

        wait(for: [encryptExpectation], timeout: 1)
    }

    func test_userLoggedOut_withExistingData_removesSessionData() {
        let session = Session(guid: "test-guid", accessToken: "test-accessToken", userIdentifier: "test-uid")

        store.stubDecryptStore { _ in
            let data: [String: Any] = ["guid": "guid", "accessToken": "accessToken", "uid": "uid"]
            let json = try! JSONSerialization.data(withJSONObject: data)
            return json
        }

        let encryptExpectation = expectation(description: "expected encrypt to be called")
        store.stubEncrypt { data, _ in
            defer { encryptExpectation.fulfill() }

            let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
            XCTAssertNil(json["guid"])
            XCTAssertNil(json["accessToken"])
            XCTAssertNil(json["uid"])
        }

        let utility = SessionBackupUtility(
            userDefaults: userDefaults,
            store: store,
            notificationCenter: notificationCenter
        )
        utility.start()

        notificationCenter.post(name: .userLoggedOut, object: session)

        wait(for: [encryptExpectation], timeout: 1)
    }
}
// swiftlint:enable force_try
