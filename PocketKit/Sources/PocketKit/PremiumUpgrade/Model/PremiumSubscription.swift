// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import SharedPocketKit
import StoreKit
import Localization

/// A type that maps to a subscription product on the App Store
public struct PremiumSubscription: Sendable {
    let product: Product

    var name: String {
        switch type {
        case .monthly:
            return Localization.monthly
        case .annual:
            return Localization.annual
        case .unknown:
            return ""
        }
    }

    var type: PremiumSubscriptionType

    /// Localized subscription price
    var price: String {
        product.displayPrice
    }

    /// Descriptive representation of the subscription type; format: `price_frequency`, where:
    ///  - `price` is the localized subscription price (e. g. $ 4.99)
    ///  - `frequency` is the renewal time, (e. g. /month)
    /// In the above example, the returned value would be $4.99/month.
    var priceDescription: String {
        price + frequency
    }

    /// Suffix of the price description
    private var frequency: String {
        switch type {
        case .monthly:
            return Self.separator + Localization.month
        case .annual:
            return Self.separator + Localization.year
        case .unknown:
            return ""
        }
    }
    private static let separator = "/"
}

extension Array where Element == PremiumSubscription {
    init(subscriptionMap: [String: PremiumSubscriptionType]) async throws {
        let productIDs = subscriptionMap.keys
        self = try await Product
            .products(for: productIDs)
            .map { product in
                PremiumSubscription(product: product, type: subscriptionMap[product.id] ?? .unknown)
            }
    }
}
