// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import SharedPocketKit

class BlankKeychain: Keychain {
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        .zero
    }

    func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus {
        .zero
    }

    func delete(query: CFDictionary) -> OSStatus {
        .zero
    }

    func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        .zero
    }
}
