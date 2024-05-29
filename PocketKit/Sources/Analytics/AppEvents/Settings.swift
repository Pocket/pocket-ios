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
    static func settingsImpression() -> Impression {
        return Impression(
            component: .screen,
            requirement: .viewable,
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

    /// Account management screen settings row tapped
    static func accountManagementRowTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.click"
            )
        )
    }

    /// Account management screen viewed
    static func accountManagementImpression() -> Impression {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings.account-management"
            )
        )
    }

    /// Delete user settings row tapped
    static func deleteRowTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.delete.click"
            )
        )
    }

    /// Delete confirmation screen impression
    static func deleteConfirmationImpression() -> Impression {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings.account-management.delete"
            )
        )
    }

    /// Help cancel premium button tapped
    static func helpCancelingPremiumTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.delete.help-cancel-premium.click"
            )
        )
    }

    /// Help canceling premium impression
    static func helpCancelingPremiumImpression() -> Impression {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings.account-management.delete.help-cancel-premium"
            )
        )
    }

    /// Delete confirmation tapped
    static func deleteConfirmationTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.delete.confirm.click"
            )
        )
    }

    /// Delete cancel tapped
    static func deleteDismissed(reason: DismissReason) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.account-management.delete.dismissed",
                componentDetail: reason.rawValue
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

    static func appBadgeToggled(newValue: Bool) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.appBadgeToggle",
                componentDetail: newValue ? "Badge Enabled" : "Badge Disabled"
            )
        )
    }

    static func appBadgePermissionDenied() -> System {
        return System(type: .appPermission(.appBadge(false)))
    }

    static func originalViewToggled(newValue: Bool) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.originalViewToggle",
                componentDetail: newValue ? "Original View Enabled" : "Original View Disabled"
            )
        )
    }

    static func appIconButtonTapped() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.appIcon.tap"
            )
        )
    }

    /// Icon selector viewed
    static func iconSelectorImpression() -> Impression {
        return Impression(
            component: .screen,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "global-nav.settings.iconSelector"
            )
        )
    }

    // App icon was changed
    static func appBadgeToggled(iconName: String) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "global-nav.settings.iconSelector.iconChanged",
                componentDetail: iconName == "Default" ? "Automatic" : iconName
            )
        )
    }
}
