// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
import Combine
import Foundation
import SharedPocketKit
import Textile
import Sync
import Localization

/// Factory to construct and inject `PremiumUpgradeViewModel` where needed
typealias PremiumUpgradeViewModelFactory = (PremiumUpgradeSource) -> PremiumUpgradeViewModel

@MainActor
class PremiumUpgradeViewModel: ObservableObject {
    private let store: SubscriptionStore
    private let tracker: Tracker
    private let source: PremiumUpgradeSource
    private let networkPathMonitor: NetworkPathMonitor

    var isOffline: Bool {
        return networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    @Published private(set) var monthlyName = ""
    @Published private(set) var monthlyPrice = ""
    @Published private(set) var monthlyPriceDescription = ""

    @Published private(set) var annualName = ""
    @Published private(set) var annualPrice = ""
    @Published private(set) var annualPriceDescription = ""
    @Published private(set) var shouldDismiss = false

    @Published var shouldShowOffline = false

    private var cancellables: Set<AnyCancellable> = []

    let offlineView = BannerModifier.BannerData(image: .looking, title: Localization.noInternetConnection, detail: Localization.Settings.NoInternet.youMustBeOnline)

    init(store: SubscriptionStore, tracker: Tracker,
         source: PremiumUpgradeSource,
         networkPathMonitor: NetworkPathMonitor) {
        self.store = store
        self.tracker = tracker
        self.source = source
        self.networkPathMonitor = networkPathMonitor

        networkPathMonitor.start(queue: .global())

        store.subscriptionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] subscriptions in
                subscriptions.forEach {
                    switch $0.type {
                    case .monthly:
                        self?.monthlyName = $0.name
                        self?.monthlyPrice = $0.price
                        self?.monthlyPriceDescription = $0.priceDescription
                    case .annual:
                        self?.annualName = $0.name
                        self?.annualPrice = $0.price
                        self?.annualPriceDescription = $0.priceDescription
                    case .unknown:
                        break
                    }
                }
            }
            .store(in: &cancellables)
        // Dismiss premium upgrade view if user is successfully upgraded to premium
        store.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  state in
                switch state {
                case .subscribed(let type):
                        self?.trackPurchaseSubscriptionSuccess(type: type)
                    self?.shouldDismiss = true
                case .unsubscribed:
                    // TODO: also do nothing here, this should only be received once when viewing the screen
                    break
                case .cancelled:
                    // TODO: probably we should just do nothing other than track the event here
                    self?.trackPurchaseSubscriptionCancelled()
                case .failed:
                    // TODO: display an alert here
                    self?.trackPurchaseSubscriptionFailed()
                }
            }
            .store(in: &cancellables)
    }

    /// Request purchaseable subscriptions to the subscription store
    func requestSubscriptions() async throws {
        try await store.requestSubscriptions()
    }

    func purchaseMonthlySubscription() async {
        guard let monthlySubscription = store.subscriptions.first(where: { $0.type == .monthly }) else {
            return
        }
        await store.purchase(monthlySubscription)
    }

    func purchaseAnnualSubscription() async {
        guard let annualSubscription = store.subscriptions.first(where: { $0.type == .annual }) else {
            return
        }
        await store.purchase(annualSubscription)
    }
}

extension PremiumUpgradeViewModel {
    func shouldShowOfflineBanner() {
        shouldShowOffline = true
    }
}

// MARK: Analytics
extension PremiumUpgradeViewModel {
    /// track Premium Upgrade View shown
    func trackPremiumUpgradeViewShown() {
        tracker.track(event: Events.Premium.premiumUpgradeViewShown(source: source))
    }
    /// track monthly button tapped
    func trackMonthlyButtonTapped() {
        tracker.track(event: Events.Premium.purchaseMonthlyButtonTapped())
    }
    /// track annual button tapped
    func trackAnnualButtonTapped() {
        tracker.track(event: Events.Premium.purchaseAnnualButtonTapped())
    }
    /// track purchase success
    /// - Parameter type: "monthly" or "annual"
    func trackPurchaseSubscriptionSuccess(type: PremiumSubscriptionType) {
        tracker.track(event: Events.Premium.purchaseSuccess(type: type))
    }
    /// track purchase subscription cancelled by the user
    func trackPurchaseSubscriptionCancelled() {
        tracker.track(event: Events.Premium.purchaseCancelled())
    }
    /// track purchase subscription failed because of an error
    func trackPurchaseSubscriptionFailed() {
        tracker.track(event: Events.Premium.purchaseFailed())
    }
}
