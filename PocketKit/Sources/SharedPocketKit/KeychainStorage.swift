// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Combine

@propertyWrapper
public class KeychainStorage<T: Codable & Equatable> {
    private let keychain: Keychain
    private let service: String
    private let account: String
    private let accessGroup: String

    private var _wrappedValue: T?
    public var wrappedValue: T? {
        get {
            if _wrappedValue == nil {
                _wrappedValue = read()
            }
            return _wrappedValue
        }
        set {
            if let newValue = newValue {
                _wrappedValue = upsert(value: newValue)
            } else {
                delete()
                _wrappedValue = nil
            }
        }
    }

    init(
        keychain: Keychain = SecItemKeychain(),
        service: String = "pocket",
        account: String,
        groupID: String
    ) {
        self.keychain = keychain
        self.service = service
        self.account = account
        self.accessGroup = groupID

        _wrappedValue = read()
    }

    private func upsert(value: T?) -> T? {
        if _wrappedValue == nil {
            return add(value: value)
        } else {
            return update(value: value)
        }
    }

    private func add(value: T?) -> T? {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return nil
        }

        let query = makeQuery([
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ])

        let status = keychain.add(query: query as CFDictionary, result: nil)
        return status == errSecSuccess ? value : nil
    }

    private func update(value: T?) -> T? {
        guard let value = value, let data = try? JSONEncoder().encode(value) else {
            return nil
        }

        let status = keychain.update(
            query: makeQuery(),
            attributes: [kSecValueData: data] as CFDictionary
        )

        return status == errSecSuccess ? value : nil
    }

    private func read() -> T? {
        let query = makeQuery([kSecReturnData: true])

        var result: AnyObject?
        let status = keychain.copyMatching(query: query, result: &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }

        return decoded
    }

    private func delete() {
        _ = keychain.delete(query: makeQuery())
    }

    private func makeQuery(_ additionalProperties: [CFString: Any] = [:]) -> CFDictionary {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: accessGroup
        ].merging(additionalProperties) { _, new in new } as CFDictionary
    }
}
