// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import RNCryptor

public protocol LegacyEncryptedStore {
    func decryptStore(securedBy password: String) throws -> Data?
    func encrypt(store: Data, securedBy password: String) throws
}

public class PocketEncryptedStore: LegacyEncryptedStore {
    /// Returns the URL of the legacy encrypted store.
    /// If this file does not exist, it will create it.
    private lazy var storeURL: URL? = {
        let groupID = "group.com.ideashower.ReadItLaterPro"
        let directory = "data"
        let filename = "PKTSharedKeyStore.json"

        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            Log.breadcrumb(category: "store", level: .info, message: "Could not find container URL for \(groupID)")
            return nil
        }

        let filepath = url.appendingPathComponent(directory).appendingPathComponent("PKTSharedKeyStore").appendingPathExtension("json")

        if FileManager.default.fileExists(atPath: filepath.path) == false {
            do {
                try FileManager.default.createDirectory(at: filepath.deletingLastPathComponent().absoluteURL, withIntermediateDirectories: false)
            } catch {
                Log.capture(error: error)
                return nil
            }

            if FileManager.default.createFile(atPath: filepath.path(), contents: Data()) == false {
                Log.capture(message: "Could not create PKTSharedKeyStore file")
                return nil
            }
        }

        return filepath
    }()

    public init() { }

    /// Reads the data of `storeURL`, decrypting it using `password`
    public func decryptStore(securedBy password: String) throws -> Data? {
        guard let storeURL = storeURL else {
            throw LegacyUserMigrationError.missingStore
        }

        let data = try Data(contentsOf: storeURL)
        if data.isEmpty {
            // Do not attempt to decrypt empty data, as decryption will fail due
            // to a missing RNCryptor header. This file will be empty if created within Pocket 8,
            // and if empty, should not attempt to be decrypted. Empty data is different
            // than missing data, which is another error that can be thrown during the decryption phase.
            throw LegacyUserMigrationError.emptyData
        }
        return try RNCryptor.decrypt(data: data, withPassword: password)
    }

    /// Writes `store` to `storeURL`, encrypting it using `password`
    public func encrypt(store: Data, securedBy password: String) throws {
        guard let storeURL = storeURL else {
            return
        }

        let encrypted = RNCryptor.encrypt(data: store, withPassword: password)
        try encrypted.write(to: storeURL)
    }
}
