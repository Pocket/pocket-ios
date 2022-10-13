import XCTest
@testable import SharedPocketKit

class BlankKeychain: Keychain {
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        .zero
    }

    func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus {
        .zero
    }

    func delete(query: CFDictionary) -> OSStatus {
        .zero
    }

    func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        .zero
    }
}

class MockEncryptedStore: LegacyEncryptedStore {
    typealias Impl = (String) throws -> Data?
    private var impl: Impl?

    func stubDecryptStore(_ impl: @escaping Impl) {
        self.impl = impl
    }

    func decryptStore(securedBy password: String) throws -> Data? {
        guard let impl = impl else {
            fatalError("decryptedStore must be stubbed before use")
        }

        return try impl(password)
    }
}

private enum MockError: Error {
    case someError
}

class LegacyUserMigrationTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var encryptedStore: MockEncryptedStore!
    private var appSession: AppSession!

    private func subject(
        userDefaults: UserDefaults? = nil,
        encryptedStore: LegacyEncryptedStore? = nil,
        appSession: AppSession? = nil
    ) -> LegacyUserMigration {
        return LegacyUserMigration(
            userDefaults: userDefaults ?? self.userDefaults,
            encryptedStore: encryptedStore ?? self.encryptedStore,
            appSession: appSession ?? self.appSession
        )
    }

    override func setUp() {
        userDefaults = UserDefaults(suiteName: "LegacyUserMigrationTests")
        encryptedStore = MockEncryptedStore()
        appSession = AppSession(keychain: BlankKeychain())
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: "LegacyUserMigrationTests")
    }
}

// MARK: - isRequired
extension LegacyUserMigrationTests {
    func test_isRequired_withPreviousVersionLessThan8_andNotRun_returnsTrue() {
        let migration = subject()
        XCTAssertTrue(migration.isRequired(version: "7.0.0"))
    }

    func test_isRequired_withPreviousVersionLessThan8_andRun_returnsFalse() {
        userDefaults.set(true, forKey: LegacyUserMigration.migrationKey)
        let migration = subject()
        XCTAssertFalse(migration.isRequired(version: "7.0.0"))
    }

    func test_isRequired_withPreviousVersionGreaterThanOrEqualTo8_andNotRun_returnsFalse() {
        var migration = subject()
        XCTAssertFalse(migration.isRequired(version: "8.0.0"))

        migration = subject()
        XCTAssertFalse(migration.isRequired(version: "9.0.0"))
    }

    func test_isRequired_withPreviousVersionGreaterThanOrEqualTo8_andRun_returnsFalse() {
        userDefaults.set(true, forKey: LegacyUserMigration.migrationKey)

        var migration = subject()
        XCTAssertFalse(migration.isRequired(version: "8.0.0"))
    }
}

// MARK: - perform (requirements)
extension LegacyUserMigrationTests {
    func test_perform_whenNotRequired_doesNotThrowError() {
        let migration = subject()
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

        XCTAssertNoThrow(try migration.perform())
    }

    func test_perform_withMissingKey_throwsError() {
        let migration = subject()

        do {
            try migration.perform()
        } catch {
            guard case LegacyUserMigrationError.missingKey = error else {
                XCTFail("Incorrect error thrown")
                return
            }
        }
    }
}

// MARK: - perform (guid)
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
            try migration.perform()
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
            try migration.perform()
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
            try migration.perform()
        } catch {
            guard case LegacyUserMigrationError.failedDeserialization = error else {
                XCTFail("Incorrect error thrown")
                return
            }
        }
    }
}

// MARK: - perform (passing)
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

        try migration.perform()

        XCTAssertEqual(appSession.currentSession?.guid, "guid")
        XCTAssertEqual(appSession.currentSession?.accessToken, "accessToken")
        XCTAssertEqual(appSession.currentSession?.userIdentifier, "uid")
    }
}
