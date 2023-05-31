// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIAlertAction {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func invoke() {
        // sadly the handler is not exposed publicly
        // so we have to do some trickery to access it
        value(forKey: "handler")
            .flatMap { unsafeBitCast($0 as AnyObject, to: AlertHandler.self) }?(self)
    }
}
