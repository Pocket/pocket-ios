// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Network
import SharedPocketKit
import Sync
import Combine
import Analytics
import Foundation

class PremiumUpsellViewModel: ObservableObject {
    private let premiumUpgradeViewModelFactory: PremiumUpgradeViewModelFactory
    private let networkPathMonitor: NetworkPathMonitor
    private let user: User
    private let source: Source
    private let tracker: Tracker

    @Published var isPresentingPremiumUpgrade = false
    @Published var isPresentingHooray = false

    var isOfflin: Bool {
        return networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    init(networkPathMonitor: NetworkPathMonitor,
         user: User,
         source: Source,
         tracker: Tracker,
         premiumUpgradeViewModelFactory: @escaping PremiumUpgradeViewModelFactory) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.source = source
        self.tracker = tracker
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory

        networkPathMonitor.start(queue: .global())
    }
}

// MARK: Premium upgrades
extension PremiumUpsellViewModel {
    @MainActor
    func makePremiumUpgradeViewModel() -> PremiumUpgradeViewModel {
        premiumUpgradeViewModelFactory(.search)
    }

    /// Ttoggle the presentation of `PremiumUpgradeView`
    func showPremiumUpgrade() {
        self.isPresentingPremiumUpgrade = true
    }

    func trackPremiumDismissed(dismissReason: DismissReason) {
        switch dismissReason {
        case .swipe, .button, .closeButton:
            tracker.track(event: Events.Premium.premiumUpgradeViewDismissed(reason: dismissReason))
        case .system:
            break
        }
    }

    func trackPremiumUpsellViewed(with itemURL: String) {
        tracker.track(event: Events.Tags.premiumUpsellViewed(itemURL: itemURL))
    }
}
