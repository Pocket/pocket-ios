// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum LegacyUserMigrationError: LoggableError {
    case missingStore
    case failedDecryption(Error)
    case missingData
    case failedDeserialization(Error)
    case emptyData
    case noSession

    public var logDescription: String {
        switch self {
        case .missingStore: return "Missing file for legacy store"
        case .failedDecryption(let error): return "Failed to decrypt store: \(error)"
        case .missingData: return "Data is missing after decrypting store"
        case .failedDeserialization(let error): return "Failed to deserialize data: \(error)"
        case .emptyData: return "Data is empty"
        case .noSession: return "No session exists in the legacy store"
        }
    }
}

public class LegacyUserMigration {
    static let migrationKey = UserDefaults.Key.legacyUserMigration
    static let orgTransferKey = UserDefaults.Key.orgTransferMigration
    // These are required for legacy migration as one-offs, and thus, should not be removed
    // from user defaults (since legacy user defaults are within the current app group)
    // So, you won't find these defined in UserDefaults.Key
    static let versionKey = "version"
    static let decryptionKey = "kPKTCryptoKey"

    private let userDefaults: UserDefaults
    private let encryptedStore: LegacyEncryptedStore
    private let appSession: AppSession
    private let keychain: Keychain
    private let groupID: String

    public init(
        userDefaults: UserDefaults,
        encryptedStore: LegacyEncryptedStore,
        appSession: AppSession,
        keychain: Keychain = SecItemKeychain(),
        groupID: String
    ) {
        self.userDefaults = userDefaults
        self.encryptedStore = encryptedStore
        self.appSession = appSession
        self.keychain = keychain
        self.groupID = groupID
    }

    func decryptUserData(with password: String) throws -> Data {
        let decryptedData: Data?
        do {
            decryptedData = try encryptedStore.decryptStore(securedBy: password)
        } catch LegacyUserMigrationError.missingStore {
            // Decryption can throw one of "two" errors - .missingStore, and
            // the rethrow of the internal decryption. We want to
            // forward the missing store to force-skip the
            // migration as necessary, since the migration shouldn't
            // have been attempted if there is no file on disk.
            // It is likely that the user has a fresh install, then.
            throw LegacyUserMigrationError.missingStore
        } catch LegacyUserMigrationError.emptyData {
            // Do not attempt to decrypt empty data, as decryption will fail due
            // to a missing RNCryptor header. This file will be empty if created within Pocket 8,
            // and if empty, should not attempt to be decrypted. Empty data is different
            // than missing data, which is another error that can be thrown during the decryption phase.
            throw LegacyUserMigrationError.emptyData
        } catch {
            throw LegacyUserMigrationError.failedDecryption(error)
        }

        guard let decryptedData = decryptedData else {
            throw LegacyUserMigrationError.missingData
        }

        return decryptedData
    }

    private func getLegacyStore(from decryptedData: Data) throws -> LegacyStore {
        do {
            return try JSONDecoder().decode(LegacyStore.self, from: decryptedData)
        } catch {
            throw LegacyUserMigrationError.failedDeserialization(error)
        }
    }

    func required(for version: String) -> Bool {
        // On a fresh install, the app will not have a "previous version", and
        // thus will not be required to run. If the previous version is < 8, then it is required.
        guard let majorComponent = version.components(separatedBy: ".").first,
              let previousMajorComponent = Int(majorComponent),
              previousMajorComponent < 8 else {
            return false
        }

        return true
    }

    @discardableResult
    public func attemptMigration(migrationWillBegin: () -> Void) throws -> Bool {
        // If we don't have a password, OR if we've already run the migration, end early.
        guard let password = currentPassword, (!previouslyRun || shouldForceForOrgTransfer) else {
            return false // If no password exists either the user never used v7 or has already migrated.
        }

        let userData = try decryptUserData(with: password)
        let legacyStore = try getLegacyStore(from: userData)

        guard required(for: legacyStore.version) || shouldForceForOrgTransfer else {
            updateUserDefaults()
            return false
        }

        guard let guid = legacyStore.guid,
              let accessToken = legacyStore.accessToken,
              let userIdentifier = legacyStore.userIdentifier
        else {
            throw LegacyUserMigrationError.noSession
        }

        migrationWillBegin()

        appSession.currentSession = Session(
            guid: guid,
            accessToken: accessToken,
            userIdentifier: userIdentifier
        )

        updateUserDefaults()
        NotificationCenter.default.post(name: .userLoggedIn, object: appSession.currentSession)
        return true
    }

    public func forceSkip() {
        updateUserDefaults()
    }
}

extension LegacyUserMigration {
    private var shouldForceForOrgTransfer: Bool {
        userDefaults.bool(forKey: Self.orgTransferKey) == false
    }

    private var previouslyRun: Bool {
        userDefaults.bool(forKey: Self.migrationKey)
    }

    private func updateUserDefaults() {
        if !userDefaults.bool(forKey: Self.migrationKey) {
            userDefaults.set(true, forKey: Self.migrationKey)
        }

        if !userDefaults.bool(forKey: Self.orgTransferKey) {
            userDefaults.set(true, forKey: Self.orgTransferKey)
        }
    }

    private var currentPassword: String? {
        // The legacy app first checks its keychain for a password for decryption,
        // followed by a user defaults fallback
        return keychainPassword ?? userDefaultsPassword ?? nil
    }

    private var keychainPassword: String? {
        LegacyPasswordRetriever(groupID: groupID, key: Self.decryptionKey).password
    }

    private var userDefaultsPassword: String? {
        userDefaults.string(forKey: Self.decryptionKey)
    }
}

private struct LegacyStore: Decodable {
    let guid: String?
    let accessToken: String?
    let userIdentifier: String?
    let version: String

    enum CodingKeys: String, CodingKey {
        case guid
        case accessToken
        case userIdentifier = "uid"
        case version
    }
}

private class LegacyPasswordRetriever {
    let password: String?

    init(groupID: String, key: String) {
        password = UserDefaults(suiteName: groupID)?.string(forKey: key)
    }
}
