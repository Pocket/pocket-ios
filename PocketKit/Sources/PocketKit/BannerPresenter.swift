// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile
import Combine
import SwiftUI

class BannerPresenter: ObservableObject {
    var bannerData: BannerModifier.BannerData?
    @Published var shouldPresentBanner = false

    private let notificationCenter: NotificationCenter
    private var subscriptions: Set<AnyCancellable> = []

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    func listen() {
        notificationCenter.publisher(for: .bannerRequested).sink { [weak self] notification in
            guard let data = notification.object as? BannerModifier.BannerData else {
                // TODO: Log?
                return
            }

            self?.bannerData = data
            self?.shouldPresentBanner = true
        }.store(in: &subscriptions)

        $shouldPresentBanner.filter({ $0 == false }).sink { [weak self] value in
            self?.bannerData = nil
        }.store(in: &subscriptions)
    }
}
