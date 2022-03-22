// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import SharedPocketKit


class MockKeychain: Keychain {
    struct AddCall {
        let query: CFDictionary
        let result: UnsafeMutablePointer<CFTypeRef?>?
    }

    struct UpdateCall {
        let query: CFDictionary
        let attributes: CFDictionary
    }

    struct DeleteCall {
        let query: CFDictionary
    }

    struct CopyMatchingCall {
        let query: CFDictionary
        let result: UnsafeMutablePointer<CFTypeRef?>?
    }

    private(set) var addCalls = Calls<AddCall>()
    private(set) var updateCalls = Calls<UpdateCall>()
    private(set) var deleteCalls = Calls<DeleteCall>()
    private(set) var copyMatchingCalls = Calls<CopyMatchingCall>()

    var addReturnVal: OSStatus = 0
    func add(query: CFDictionary, result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        addCalls.add(AddCall(query: query, result: result))
        return addReturnVal
    }

    var updateReturnVal: OSStatus = 0
    func update(query: CFDictionary, attributes: CFDictionary) -> OSStatus {
        updateCalls.add(UpdateCall(query: query, attributes: attributes))
        return updateReturnVal
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
