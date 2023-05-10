// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
import Textile
import Combine
import SharedPocketKit

/// Listens for general notifications and reroutes them to the appropriate NotificationCentre instance
class NotificationRelay {
    private let broadcastNotificationCentre: NotificationCenter
    private var subscriptions: Set<AnyCancellable> = []

    private var serverErrorActions: [Int: () -> Void] = [:]

    init(_ broadcastNotificationCentre: NotificationCenter) {
        self.broadcastNotificationCentre = broadcastNotificationCentre

        registerActions()
        registerSubscriptions()
    }

    private func registerSubscriptions() {
        NotificationCenter.default.publisher( for: .serverError)
            .sink { [weak self] notification in
                self?.serverError(notification)
            }.store(in: &subscriptions)
    }

    private func registerActions() {
        serverErrorActions[429] = notRespondingError
        serverErrorActions[503] = notRespondingError
        serverErrorActions[500] = serverError
    }

    private func serverError(_ notification: Notification) {
        guard let HTTPError = notification.object as? Int else {
            Log.warning("ServerError did not recieve a valid HTTP Error code")
            return
        }

        guard let action = serverErrorActions[HTTPError] else {
            Log.warning("Unanticipated HTTP Error code")
            return
        }

        action()
    }

    private func notRespondingError() {
        let errorMessage = Localization.General.Error.ServerNotResponding.self
        
        let bannerData = BannerModifier.BannerData(
            image: .warning,
            title: errorMessage.title,
            detail: errorMessage.detail
        )

        broadcastNotificationCentre.post(name: .bannerRequested, object: bannerData)
    }

    private func serverError() {
        let bannerData = BannerModifier.BannerData(
            image: .warning,
            title: nil,
            detail: Localization.General.Error.serverError
        )

        broadcastNotificationCentre.post(name: .bannerRequested, object: bannerData)
    }
}
