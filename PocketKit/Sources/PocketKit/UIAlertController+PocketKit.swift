// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIAlertController {
    convenience init(_ alert: PocketAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: alert.preferredStyle)

        alert.actions.forEach(self.addAction)
        self.preferredAction = alert.preferredAction
    }
}
