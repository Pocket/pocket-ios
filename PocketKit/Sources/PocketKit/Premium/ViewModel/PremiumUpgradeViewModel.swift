// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Foundation
import SharedPocketKit

@MainActor
class PremiumUpgradeViewModel: ObservableObject {
    let store: SubscriptionStore

    @Published private(set) var monthlyName = ""
    @Published private(set) var monthlyPrice = ""
    @Published private(set) var monthlyPriceDescription = ""

    @Published private(set) var annualName = ""
    @Published private(set) var annualPrice = ""
    @Published private(set) var annualPriceDescription = ""
    @Published private(set) var shouldDismiss = false

    private var cancellables: Set<AnyCancellable> = []

    init(store: SubscriptionStore) {
        self.store = store

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
        store.purchasedSubscriptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  subscription in
                if subscription != nil {
                    self?.shouldDismiss = true
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
