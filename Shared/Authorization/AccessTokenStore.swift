// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync


class AccessTokenStore {
    enum Error: Swift.Error {
        case secItemError(OSStatus)
    }

    private let keychain: Keychain

    init(keychain: Keychain) {
        self.keychain = keychain
    }

    var accessToken: String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var result: CFTypeRef?
        _ = keychain.copyMatching(
            query: query as CFDictionary,
            result: &result
        )

        guard let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    func save(token: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier!,
            kSecValueData as String: token.data(using: .utf8)!
        ]

        let status = keychain.add(
            query: query as CFDictionary,
            result: nil
        )

        if status != errSecSuccess {
            throw Error.secItemError(status)
        }
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier!,
        ]

        let status = keychain.delete(query: query as CFDictionary)
        if status != errSecSuccess {
            throw Error.secItemError(status)
        }
    }
}

extension AccessTokenStore: AccessTokenProvider {

}
