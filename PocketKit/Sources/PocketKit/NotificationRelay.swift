// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import Textile

/// Listens for general notifications and reroutes them to the appropriate NotificationCentre instance
class NotificationRelay {
    let broadcastNotificationCentre: NotificationCenter

    init(_ broadcastNotificationCentre: NotificationCenter) {
        self.broadcastNotificationCentre = broadcastNotificationCentre

        registerObservers()
    }

    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(serverError(_:)), name: .serverError, object: nil)
    }

    @objc public func serverError(_ notification: Notification) {

        let bannerData = BannerModifier.BannerData(
            image: .warning,
            title: nil,
            detail: Localization.General.Error.serverThrottle
        )

        broadcastNotificationCentre.post(name: .bannerRequested, object: bannerData)
    }
}
