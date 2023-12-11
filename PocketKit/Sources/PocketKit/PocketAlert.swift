// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Localization

struct PocketAlert {
    let title: String?
    let message: String?
    let preferredStyle: UIAlertController.Style
    let actions: [UIAlertAction]
    let preferredAction: UIAlertAction?
}

extension PocketAlert {
    init(_ error: Error, handler: @escaping () -> Void) {
        self.init(
            title: Localization.anErrorOccurred,
            message: error.localizedDescription,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.ok, style: .default) { _ in
                    handler()
                }
            ],
            preferredAction: nil
        )
    }
}
