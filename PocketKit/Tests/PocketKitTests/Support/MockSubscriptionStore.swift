// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import PocketKit
import SharedPocketKit

class MockSubscriptionStore: SubscriptionStore {
    func restoreSubscription() async throws {}
    @Published var subscriptions: [PocketKit.PremiumSubscription] = []
    var subscriptionsPublisher: Published<[PocketKit.PremiumSubscription]>.Publisher { $subscriptions }
    @Published var state: PurchaseState = .unsubscribed
    var statePublisher: Published<PurchaseState>.Publisher { $state }
    func requestSubscriptions() async throws {}
    func purchase(_ subscription: PocketKit.PremiumSubscription) async {}
}
