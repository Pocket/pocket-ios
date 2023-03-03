// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct Premium {}
}

public extension Events.Premium {
    /// Premium Upgrade View appears
    /// - Parameter source: "settings" or "search"
    static func premiumUpgradeViewShown(source: String) -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.premium",
                componentDetail: source
            )
        )
    }

    /// Monthly Subscription button tapped
    static func purchaseMonthlyButtonTapped() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.premium.monthly"
            )
        )
    }

    /// Annual Subscription button tapped
    static func purchaseAnnualButtonTapped() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.premium.annual"
            )
        )
    }

    /// Visual confirmation of successful subscription purchase
    /// - Parameter type: "monthly" or "annual
    static func purchaseSuccess(type: String) -> Event {
        return Impression(
            component: .dialog,
            requirement: .viewable,
            uiEntity: UiEntity(
                .dialog,
                identifier: "global-nav.premium.purchase.success"
            )
        )
    }

    /// Visual confirmation of subscription purchase failed
    static func purchaseFailed() -> Event {
        return Impression(
            component: .dialog,
            requirement: .viewable,
            uiEntity: UiEntity(
                .dialog,
                identifier: "global-nav.premium.purchase.failed"
            )
        )
    }

    /// Subscription purchase cancelled by the user
    static func purchaseCancelled() -> Event {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.premium.purchase.cancelled"
            )
        )
    }

    /// Premium Upgrade View dismissed by the user
    /// - Parameter action: "button" or "swipe"
    static func premiumUpgradeViewDismissed(reason: DismissReason) -> Event {
        print("Dismiss called with \(reason.rawValue)")
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.premium.dismiss",
                componentDetail: reason.rawValue
            )
        )
    }
}
