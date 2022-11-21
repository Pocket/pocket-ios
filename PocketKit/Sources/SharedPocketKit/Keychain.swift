// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol Keychain {
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
    func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus
    func delete(query: CFDictionary) -> OSStatus
    func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus
}

public struct SecItemKeychain: Keychain {
    public init() { }

    public func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        return SecItemAdd(query, result)
    }

    public func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus {
        return SecItemUpdate(query, attributes)
    }

    public func delete(query: CFDictionary) -> OSStatus {
        return SecItemDelete(query)
    }

    public func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        return SecItemCopyMatching(query, result)
    }
}
