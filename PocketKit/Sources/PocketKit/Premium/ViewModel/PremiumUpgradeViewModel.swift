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

    @Published var monthlySubscriptionName = ""
    @Published var monthlySubscriptionPriceDescription = ""

    @Published var annualSubscriptionName = ""
    @Published var annualSubscriptionPriceDescription = ""

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
                    self?.monthlySubscriptionName = $0.name
                    self?.monthlySubscriptionPriceDescription = $0.priceDescription
                case .annual:
                    self?.annualSubscriptionName = $0.name
                    self?.annualSubscriptionPriceDescription = $0.priceDescription
                case .none:
                    break
                }
            }
        }
    }
}
