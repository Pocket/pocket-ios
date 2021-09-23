// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


class AsyncOperation: Operation {
    override var isAsynchronous: Bool {
        true
    }

    private var _isFinished = false
    override var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            guard newValue != _isFinished else {
                return
            }

            willChangeValue(for: \.isFinished)
            _isFinished = newValue
            didChangeValue(for: \.isFinished)
        }
    }

    private var _isExecuting = false
    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            guard newValue != _isExecuting else {
                return
            }

            willChangeValue(for: \.isExecuting)
            _isExecuting = newValue
            didChangeValue(for: \.isExecuting)
        }
    }

    func finishOperation() {
        isExecuting = false
        isFinished = true
    }
}
