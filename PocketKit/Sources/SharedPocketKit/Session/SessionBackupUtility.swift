// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Combine
import RNCryptor

/**
 A utility class that can back up a `SharedPocketKit.Session` to an encrypted legacy Pocket store.
 This is done by adding / modifying existing key/value pairs in the store.
 - Note: The utility of this class is that we will want to force-run the legacy migration
 after transferring orgs, and a Pocket 8-only user won't have a pre-existing (required) store.
 By backing up a session, we can create this store (or update a pre-existing one) as necessary.
 */
public class SessionBackupUtility {
    /// The decryption key used in conjunction with `store`.
    private let password: String

    private let userDefaults: UserDefaults
    private let store: LegacyEncryptedStore
    private let notificationCenter: NotificationCenter

    private let notificationQueue = DispatchQueue(label: "SessionBackupUtility", qos: .utility)
    private var subscriptions: Set<AnyCancellable> = []

    public init(userDefaults: UserDefaults, store: LegacyEncryptedStore, notificationCenter: NotificationCenter) {
        self.userDefaults = userDefaults
        self.store = store
        self.notificationCenter = notificationCenter

        // Return an existing decryption key, else create + store a new one, and return that
        if let existing = userDefaults.string(forKey: LegacyUserMigration.decryptionKey) {
            self.password = existing
        } else {
            // Generate a password the same way as the legacy app
            let password = RNCryptor.randomData(ofLength: 32).base64EncodedString()
            userDefaults.set(password, forKey: LegacyUserMigration.decryptionKey)
            self.password = password
        }
    }

    public func start() {
        // Utilize NotificationCenter to save a user session on-disk after a user has logged in
        notificationCenter.publisher(for: .userLoggedIn)
            .receive(on: notificationQueue)
            .sink { [weak self] notification in
                guard let self = self, let session = notification.object as? Session else {
                    return
                }

                do {
                    try self.save(session: session)
                    Log.breadcrumb(category: "session", level: .info, message: "Successfully backed up logged in session.")
                } catch {
                    Log.capture(error: error)
                }
            }.store(in: &subscriptions)

        // Utilize NotificationCenter to reset a user session on-disk after a user has logged out
        notificationCenter.publisher(for: .userLoggedOut)
            .receive(on: notificationQueue)
            .sink { [weak self] notification in
                guard let self = self else {
                    return
                }

                do {
                    try self.save(session: nil)
                    Log.breadcrumb(category: "session", level: .info, message: "Successfully backed up logged out session.")
                } catch {
                    Log.capture(error: error)
                }
            }.store(in: &subscriptions)
    }

    /// Saves a `SharedPocketKit.Session` to `store`, adding / modifying existing key/value pairs
    ///  within the store to contain the requested Session data.
    private func save(session: Session?) throws {
        let data: Data
        do {
            // `decryptStore` will throw if the on-disk store was
            // empty, or if something went wrong. We want to continue saving
            // the session, though, so we will default to empty data and continue.
            // This assumes that if the file already existed (via Pocket 7), that this won't throw,
            // and will only throw if the file was empty (i.e empty when created by Pocket 8).
            data = try store.decryptStore(securedBy: password) ?? Data()
        } catch {
            // TODO: Something better?
            Log.breadcrumb(category: "session", level: .info, message: "Failed decrypting store: \(error); creating empty data")
            data = Data()
        }

        let initial: [String: Any]

        if data.isEmpty { // data will be empty if the store has been created in Pocket 8
            initial = [:]
        } else { // data will not be empty if previously created, either in Pocket 7 or 8
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            initial = json
        }

        let updated = update(initial, with: session)

        do {
            let serialized = try JSONSerialization.data(withJSONObject: updated)
            try store.encrypt(store: serialized, securedBy: password)
        } catch {
            Log.capture(error: error)
        }
    }

    private func update(_ json: [String: Any], with session: Session?) -> [String: Any] {
        var json = json // We want to mutate a copy, rather than the original
        if let session = session {
            json["guid"] = session.guid
            json["accessToken"] = session.accessToken
            json["uid"] = session.userIdentifier // uid == userIdentifier in the legacy store
            json["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        } else {
            json.removeValue(forKey: "guid")
            json.removeValue(forKey: "accessToken")
            json.removeValue(forKey: "uid")
        }

        return json
    }
}
