// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import StoreKit

/// A type that handles premium subscriptions purchases from the App Store
final class PremiumSubscriptionStore: ObservableObject {
    @Published private(set) var subscriptions: [PremiumSubscription] = []

    init() async throws {
        try await requestSubscriptions()
    }
    @MainActor
    func requestSubscriptions() async throws {
        subscriptions = try await .init()
    }
}
