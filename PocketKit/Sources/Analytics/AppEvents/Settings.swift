// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct Settings {}
}

public extension Events.Settings {
    /// Fired when a user views the settings screen
    static func settingsViewed() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings"
            )
        )
    }

    /// Logout tapped
    static func logoutRowTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.logout"
            )
        )
    }

    /// Logout tapped
    static func logoutConfirmTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.logout-confirmed"
            )
        )
    }

    /// Account management screen viewed
    static func accountManagementViewed() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings.account-management"
            )
        )
    }

    /// Delete confirmation screen viewed
    static func deleteConfirmationViewed() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings.account-management.delete-confirmation"
            )
        )
    }

    /// Help cancel premium button tapped
    static func helpCancelingPremiumTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.delete-confirmation.help-cancel-premium"
            )
        )
    }

    /// Delete tapped
    static func deleteTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.delete-confirmation.delete"
            )
        )
    }

    /// "Go Premium" button viewed
    static func premiumUpsellViewed() -> Event {
        return Impression(
            component: .button,
            requirement: .viewable,
            uiEntity: UiEntity(
                .button,
                identifier: "account.premium.upsell"
            )
        )
    }
}
