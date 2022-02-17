// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


protocol Keychain {
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus

    func delete(query: CFDictionary) -> OSStatus

    func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
}

struct SecItemKeychain: Keychain {
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        return SecItemAdd(query, result)
    }

    func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus {
        return SecItemUpdate(query, attributes)
    }

    func delete(query: CFDictionary) -> OSStatus {
        return SecItemDelete(query)
    }

    func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        return SecItemCopyMatching(query, result)
    }
}
