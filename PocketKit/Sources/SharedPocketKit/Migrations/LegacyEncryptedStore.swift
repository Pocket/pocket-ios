import Foundation
import RNCryptor

public protocol LegacyEncryptedStore {
    func decryptStore(securedBy password: String) throws -> Data?
}

public class PocketEncryptedStore: LegacyEncryptedStore {
    private lazy var storeURL: URL? = {
        let groupID = "group.com.ideashower.ReadItLaterPro"
        let directory = "data"
        let filename = "PKTSharedKeyStore.json"

        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }

        let filepath = url.appendingPathComponent(directory).appendingPathComponent("PKTSharedKeyStore").appendingPathExtension("json")

        guard FileManager.default.fileExists(atPath: filepath.path) else {
            return nil
        }

        return url
    }()

    public init() { }

    public func decryptStore(securedBy password: String) throws -> Data? {
        guard let storeURL = storeURL else {
            throw LegacyUserMigrationError.missingStore
        }

        let data = try Data(contentsOf: storeURL)
        return try RNCryptor.decrypt(data: data, withPassword: password)
    }
}
