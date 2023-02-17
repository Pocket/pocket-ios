// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import StoreKit

/// An enum that maps all available subscription IDs on the App Store
enum PremiumSubscriptionType: CaseIterable {
    case monthly
    case annual

    var id: String {
        switch self {
        case .monthly:
            return Keys.shared.pocketPremiumMonthly
        case .annual:
            return Keys.shared.pocketPremiumAnnual
        }
    }

    static func type(from productId: String) -> Self? {
        switch productId {
        case Keys.shared.pocketPremiumMonthly:
            return .monthly
        case Keys.shared.pocketPremiumAnnual:
            return .annual
        default:
            return .none
        }
    }
}

/// A type that maps to a subscription product on the App Store
struct PremiumSubscription {
    let product: Product
    var isPurchased = false

    var name: String {
        switch type {
        case .monthly:
            return L10n.monthly
        case .annual:
            return L10n.annual
        case .none:
            return ""
        }
    }

    var priceDescription: String {
        product.displayPrice + priceDescriptionSuffix
    }

    var type: PremiumSubscriptionType? {
        PremiumSubscriptionType.type(from: product.id)
    }

    private var priceDescriptionSuffix: String {
        switch type {
        case .monthly:
            return "/" + L10n.month
        case .annual:
            return "/" + L10n.year
        case .none:
            return ""
        }
    }
}

extension Array where Element == PremiumSubscription {
    init() async throws {
        self = try await Product
            .products(for: PremiumSubscriptionType.allCases.map { $0.id })
            .map {
                PremiumSubscription(product: $0)
            }
    }
}
