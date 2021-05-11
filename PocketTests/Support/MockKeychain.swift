// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import Pocket


class MockKeychain: Keychain {
    struct AddCall {
        let query: CFDictionary
        let result: UnsafeMutablePointer<CFTypeRef?>?
    }

    struct DeleteCall {
        let query: CFDictionary
    }

    struct CopyMatchingCall {
        let query: CFDictionary
        let result: UnsafeMutablePointer<CFTypeRef?>?
    }

    private(set) var addCalls = Calls<AddCall>()
    private(set) var deleteCalls = Calls<DeleteCall>()
    private(set) var copyMatchingCalls = Calls<CopyMatchingCall>()

    var addReturnVal: OSStatus = 0
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        addCalls.add(AddCall(query: query, result: result))
        return addReturnVal
    }

    var copyMatchingReturnVal: OSStatus = 0
    var copyMatchingResult: CFTypeRef?
    func copyMatching(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        copyMatchingCalls.add(CopyMatchingCall(query: query, result: result))
        result?.pointee = copyMatchingResult
        return copyMatchingReturnVal
    }

    var deleteReturnVal: OSStatus = 0
    func delete(query: CFDictionary) -> OSStatus {
        deleteCalls.add(DeleteCall(query: query))
        return deleteReturnVal
    }
}
