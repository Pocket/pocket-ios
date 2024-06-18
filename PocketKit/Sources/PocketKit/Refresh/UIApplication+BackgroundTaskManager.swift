// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync

// TODO: CONCURRENCY - Reinstate @retroactive directive once we migrate to Xcode 16
extension UIApplication: BackgroundTaskManager {
    public func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> Int {
        beginBackgroundTask(withName: name, expirationHandler: expirationHandler).rawValue
    }

    public func endTask(_ identifier: Int) {
        endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: identifier))
    }
}
