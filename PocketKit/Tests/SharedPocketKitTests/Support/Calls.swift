// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.


struct Calls<T> {
    private var calls: [T] = []

    mutating func add(_ call: T) {
        calls.append(call)
    }

    var wasCalled: Bool {
        !calls.isEmpty
    }

    var last: T? {
        return calls.last
    }
    
    var count: Int {
        return calls.count
    }

    subscript(index: Int) -> T {
        calls[index]
    }
}
