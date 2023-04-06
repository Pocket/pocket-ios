import Foundation

public enum LegacyUserMigrationError: LoggableError {
    case missingKey
    case missingStore
    case failedDecryption(Error)
    case missingData
    case failedDeserialization(Error)

    public var logDescription: String {
        switch self {
        case .missingKey: return "Missing decryption key for legacy user migration"
        case .missingStore: return "Missing file for legacy store"
        case .failedDecryption(let error): return "Failed to decrypt store: \(error)"
        case .missingData: return "Data is missing after decrypting store"
        case .failedDeserialization(let error): return "Failed to deserialize data: \(error)"
        }
    }
}

public class LegacyUserMigration {
    static let migrationKey = "com.mozilla.pocket.next.migration.legacyUser"
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

    func decryptUserData() throws -> Data {
        guard let password = currentPassword else {
            throw LegacyUserMigrationError.missingKey
        }

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

    @discardableResult
    public func perform(migrationWillBegin: () -> Void) throws -> Bool {

        let userData = try decryptUserData()
        let legacyStore = try getLegacyStore(from: userData)

        guard isRequired(version: legacyStore.version) else {
            updateUserDefaults()
            return false
        }

        migrationWillBegin()

        appSession.currentSession = Session(
            guid: legacyStore.guid,
            accessToken: legacyStore.accessToken,
            userIdentifier: legacyStore.userIdentifier
        )

        updateUserDefaults()
        return true
    }

    public func forceSkip() {
        updateUserDefaults()
    }
}

extension LegacyUserMigration {
    func isRequired(version: String) -> Bool {
        // On a fresh install, the app will not have a "previous version", and
        // thus will not be required to run. If the previous version is < 8,
        // and we have not yet run the migration, then it is required.
        return required(for: version) && !previouslyRun
    }

    private var previouslyRun: Bool {
        userDefaults.bool(forKey: Self.migrationKey)
    }

    private func required(for version: String) -> Bool {
        guard let majorComponent = version.components(separatedBy: ".").first,
              let previousMajorComponent = Int(majorComponent),
              previousMajorComponent < 8 else {
            return false
        }

        return true
    }

    private func updateUserDefaults() {
        if !userDefaults.bool(forKey: Self.migrationKey) {
            userDefaults.set(true, forKey: Self.migrationKey)
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
    let guid: String
    let accessToken: String
    let userIdentifier: String
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
