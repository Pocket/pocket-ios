// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SharedPocketKit

/// Subscription store error(s)
enum SubscriptionStoreError: LoggableError {
    case unverifiedPurchase
    case purchaseFailed
    case invalidProduct

    var logDescription: String {
        switch self {
        case .unverifiedPurchase: return "Unverified purchase"
        case .purchaseFailed: return "Purchase failed"
        case .invalidProduct: return "Invalid product"
        }
    }
}

/// Describes the state of a purchase made from a `SubscriptionStore`
public enum PurchaseState {
    case unsubscribed
    case subscribed(PremiumSubscriptionType)
    case cancelled
    case failed
}

/// Generic type representing a subscription store
@MainActor
public protocol SubscriptionStore {
    var subscriptions: [PremiumSubscription] { get }
    var subscriptionsPublisher: Published<[PremiumSubscription]>.Publisher { get }
    var state: PurchaseState { get }
    var statePublisher: Published<PurchaseState>.Publisher { get }
    func requestSubscriptions() async throws
    func purchase(_ subscription: PremiumSubscription) async
    func restoreSubscription() async throws
    func start()
}
