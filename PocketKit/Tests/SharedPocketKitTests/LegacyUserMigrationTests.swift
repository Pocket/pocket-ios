// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import RNCryptor
@testable import SharedPocketKit

// swiftlint:disable force_try

private enum MockError: Error {
    case someError
}

class LegacyUserMigrationTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var encryptedStore: MockEncryptedStore!
    private var appSession: AppSession!
    private var keychain: MockKeychain!
    private var groupID: String!

    private func subject(
        userDefaults: UserDefaults? = nil,
        encryptedStore: LegacyEncryptedStore? = nil,
        appSession: AppSession? = nil,
        keychain: Keychain? = nil,
        groupID: String? = nil
    ) -> LegacyUserMigration {
        return LegacyUserMigration(
            userDefaults: userDefaults ?? self.userDefaults,
            encryptedStore: encryptedStore ?? self.encryptedStore,
            appSession: appSession ?? self.appSession,
            keychain: keychain ?? self.keychain,
            groupID: groupID ?? self.groupID
        )
    }

    override func setUp() {
        super.setUp()
        groupID = "group.com.mozilla.test"
        userDefaults = UserDefaults(suiteName: "LegacyUserMigrationTests")
        encryptedStore = MockEncryptedStore()
        appSession = AppSession(keychain: BlankKeychain(), groupID: groupID)
        keychain = MockKeychain()
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: "LegacyUserMigrationTests")
        super.tearDown()
    }
}

// MARK: - isRequired
extension LegacyUserMigrationTests {
    func test_isRequired_withPreviousVersionLessThan8_andNotRun_returnsTrue() {
        let migration = subject()
        XCTAssertTrue(migration.required(for: "7.0.0"))
    }

    func test_isRequired_withPreviousVersionGreaterThanOrEqualTo8_andNotRun_returnsFalse() {
        var migration = subject()
        XCTAssertFalse(migration.required(for: "8.0.0"))

        migration = subject()
        XCTAssertFalse(migration.required(for: "9.0.0"))
    }
}

// MARK: - attemptMigration (requirements)
extension LegacyUserMigrationTests {
    func test_perform_whenNotRequired_doesNotThrowError() {
        let migration = subject()
        userDefaults.set(true, forKey: LegacyUserMigration.orgTransferKey)
        userDefaults.set(true, forKey: LegacyUserMigration.migrationKey)
        userDefaults.set("key", forKey: LegacyUserMigration.decryptionKey)
        encryptedStore.stubDecryptStore { key in
            let correct: [String: Any] = [
                "guid": "guid",
                "accessToken": "accessToken",
                "uid": "uid",
                "version": "7.0.0"
            ]

            return try! JSONSerialization.data(withJSONObject: correct)
        }

        XCTAssertNoThrow(try migration.attemptMigration {
            XCTFail("Migration should not be attempted")
        })
    }

    func test_perform_withMissingKeyInKeychainAndDefaults() {
        let migration = subject()

        do {
            let result = try migration.attemptMigration {
                XCTFail("Migration should not be attempted")
            }

            XCTAssertFalse(result, "Migration should not be attempted")
        } catch {
            XCTFail("Error should not be thrown")
        }
    }
}

// MARK: - attemptMigration (guid)
// For these tests to correctly function, implement the same stub
// for all keys (since guid is checked first)
extension LegacyUserMigrationTests {
    func test_perform_storeFailedDecryption_throwsError() {
        let migration = subject()
        userDefaults.set("key", forKey: "kPKTCryptoKey")
        encryptedStore.stubDecryptStore { _ in
            throw MockError.someError
        }

        do {
            try migration.attemptMigration {
                XCTFail("Migration should not be attempted")
            }
        } catch {
            guard case LegacyUserMigrationError.failedDecryption = error else {
                XCTFail("Incorrect error thrown")
                return
            }
        }
    }

    func test_perform_storeReturnedNilData_throwsError() {
        let migration = subject()
        userDefaults.set("key", forKey: "kPKTCryptoKey")
        encryptedStore.stubDecryptStore { _ in
            return nil
        }

        do {
            try migration.attemptMigration {
                XCTFail("Migration should not be attempted")
            }
        } catch {
            guard case LegacyUserMigrationError.missingData = error else {
                XCTFail("Incorrect error thrown")
                return
            }
        }
    }

    func test_perform_storeReturnedIncorrectData_throwsError() {
        let migration = subject()
        userDefaults.set("key", forKey: "kPKTCryptoKey")
        encryptedStore.stubDecryptStore { _ in
            let incorrect: [String: Any] = [
                "guid": "guid"
            ]

            return try! JSONSerialization.data(withJSONObject: incorrect)
        }

        do {
            try migration.attemptMigration {
                XCTFail("Migration should not be attempted")
            }
        } catch {
            guard case LegacyUserMigrationError.failedDeserialization = error else {
                XCTFail("Incorrect error thrown")
                return
            }
        }
    }

    func test_perform_storeReturnedMissingSessionData_throwsError() {
        userDefaults.set("key", forKey: "kPKTCryptoKey")

        let migration = subject()
        encryptedStore.stubDecryptStore { _ in
            let incorrect: [String: Any] = [
                "version": "8.0.0"
            ]

            return try! JSONSerialization.data(withJSONObject: incorrect)
        }

        do {
            try migration.attemptMigration {
                XCTFail("Migration should not be attempted")
            }
        } catch {
            guard case LegacyUserMigrationError.noSession = error else {
                XCTFail("Incorrect error thrown")
                return
            }
        }
    }
}

// MARK: - attemptMigration (passing)
extension LegacyUserMigrationTests {
    func test_perform_allValid_updatesAppSession() throws {
        // Required to regenerate migration with updated infoDictionary since infoDictionary
        // is a value type, and thus pass-by-copy
        userDefaults.set("7.0.0", forKey: LegacyUserMigration.versionKey)
        let migration = subject()

        userDefaults.set("key", forKey: LegacyUserMigration.decryptionKey)
        encryptedStore.stubDecryptStore { key in
            let correct: [String: Any] = [
                "guid": "guid",
                "accessToken": "accessToken",
                "uid": "uid",
                "version": "7.0.0"
            ]

            return try! JSONSerialization.data(withJSONObject: correct)
        }

        let expectation = XCTestExpectation(description: "Migration event fired successfully.")

        try migration.attemptMigration {
            expectation.fulfill()
        }

        XCTAssertEqual(appSession.currentSession?.guid, "guid")
        XCTAssertEqual(appSession.currentSession?.accessToken, "accessToken")
        XCTAssertEqual(appSession.currentSession?.userIdentifier, "uid")

        wait(for: [expectation], timeout: 5)
    }
}

// MARK: - org transfer
extension LegacyUserMigrationTests {
    // App update path from 7 (old org) -> 8 (new org, transfer)
    func test_perform_whenOrgTransferNotCompleted_andOtherwiseNotCompleted_updatesSession() throws {
        userDefaults.set("key", forKey: LegacyUserMigration.decryptionKey)
        let migration = subject()

        encryptedStore.stubDecryptStore { key in
            let correct: [String: Any] = [
                "guid": "guid",
                "accessToken": "accessToken",
                "uid": "uid",
                "version": "7.0.0"
            ]

            return try! JSONSerialization.data(withJSONObject: correct)
        }

        let result = try migration.attemptMigration { }

        XCTAssertTrue(result)
        XCTAssertEqual(appSession.currentSession?.guid, "guid")
        XCTAssertEqual(appSession.currentSession?.accessToken, "accessToken")
        XCTAssertEqual(appSession.currentSession?.userIdentifier, "uid")
    }

    // App update path from 7 (old org) -> 8 (old org, complete) -> 8 (new org, transfer)
    func test_perform_whenOrgTransferNotCompleted_butOtherwiseCompleted_updatesSession() throws {
        userDefaults.set(true, forKey: LegacyUserMigration.migrationKey)
        userDefaults.set("key", forKey: LegacyUserMigration.decryptionKey)
        let migration = subject()

        encryptedStore.stubDecryptStore { key in
            let correct: [String: Any] = [
                "guid": "guid",
                "accessToken": "accessToken",
                "uid": "uid",
                "version": "8.0.0"
            ]

            return try! JSONSerialization.data(withJSONObject: correct)
        }

        let result = try migration.attemptMigration { }

        XCTAssertTrue(result)
        XCTAssertEqual(appSession.currentSession?.guid, "guid")
        XCTAssertEqual(appSession.currentSession?.accessToken, "accessToken")
        XCTAssertEqual(appSession.currentSession?.userIdentifier, "uid")
    }

    // App update path from: 7 (old org) -> 8 (new org, already transferred)
    // or 8 (old org) -> 8 (new org, already transferred)
    func test_perform_whenOrgTransferCompleted_doesNotRun() {
        userDefaults.set(true, forKey: UserDefaults.Key.orgTransferMigration)
        let migration = subject()

        do {
            let result = try migration.attemptMigration {
                XCTFail("Migration should not be attempted")
            }

            XCTAssertFalse(result, "Migration should not be attempted")
        } catch {
            XCTFail("Error should not be thrown")
        }
    }
}

// swiftlint:enable force_try
