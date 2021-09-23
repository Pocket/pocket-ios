// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Analytics
import Sync


class MainCoordinator {
    var viewController: UIViewController {
        regular.viewController
    }

    private let compact: CompactMainCoordinator
    private let regular: RegularMainCoordinator

    init(
        model: MainViewModel,
        source: Source,
        tracker: Tracker
    ) {
        compact = CompactMainCoordinator(
            source: source,
            tracker: tracker,
            model: model
        )

        regular = RegularMainCoordinator(
            source: source,
            tracker: tracker,
            model: model
        )

        regular.setCompactViewController(compact.viewController)
    }

    func showList() {
        regular.showSupplementary()
    }
}
