// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Foundation
import SharedPocketKit

@MainActor
class PremiumUpgradeViewModel: ObservableObject {
    private let storeFactory: () async throws -> PremiumSubscriptionStore

    private var store: PremiumSubscriptionStore?

    @Published private(set) var monthlyName = ""
    @Published private(set) var monthlyPrice = ""
    @Published private(set) var monthlyPriceDescription = ""

    @Published private(set) var annualName = ""
    @Published private(set) var annualPrice = ""
    @Published private(set) var annualPriceDescription = ""

    private var cancellable: AnyCancellable?

    init(storeFactory: @escaping () async throws -> PremiumSubscriptionStore) {
        self.storeFactory = storeFactory
    }

    /// Initialize the subscription store and retrieve subscriptions
    func requestSubscriptions() async throws {
        self.store = try await storeFactory()

        cancellable = store?.$subscriptions
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
                case .none:
                    break
                }
            }
        }
    }
}
