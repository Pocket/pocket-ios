// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import SharedPocketKit

class MockEncryptedStore: LegacyEncryptedStore {
    private var implementations: [String: Any] = [:]

    private static let decrypt = "decrypt"
    typealias DecryptImpl = (String) throws -> Data?

    func stubDecryptStore(_ impl: @escaping DecryptImpl) {
        implementations[Self.decrypt] = impl
    }

    func decryptStore(securedBy password: String) throws -> Data? {
        guard let impl = implementations[Self.decrypt] as? DecryptImpl else {
            fatalError("decryptedStore must be stubbed before use")
        }

        return try impl(password)
    }
}

extension MockEncryptedStore {
    private static let encrypt = "encrypt"
    typealias EncryptImpl = (Data, String) throws -> Void

    func stubEncrypt(_ impl: @escaping EncryptImpl) {
        implementations[Self.encrypt] = impl
    }

    func encrypt(store: Data, securedBy password: String) throws {
        guard let impl = implementations[Self.encrypt] as? EncryptImpl else {
            fatalError("encrypt must be stubbed before use")
        }

        try impl(store, password)
    }
}
