// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct Login {}
}

// MARK: Delete Account Events
public extension Events.Login {
    /// Fired when a user sees the exit survey banner
    static func deleteAccountExitSurveyBannerImpression() -> Impression {
        return Impression(
            component: .ui,
            requirement: .viewable,
            uiEntity: UiEntity(
                .dialog,
                identifier: "login.accountdelete.banner"
            )
        )
    }

    /// Fired when a user taps the exit survey banner
    static func deleteAccountExitSurveyBannerTap() -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "login.accountdelete.banner.exitsurvey.click"
            )
        )
    }

    /// Fired when a user sees the exit survey
    static func deleteAccountExitSurveyImpression() -> Impression {
        return Impression(
            component: .ui,
            requirement: .viewable,
            uiEntity: UiEntity(
                .screen,
                identifier: "login.accountdelete.exitsurvey"
            )
        )
    }

    /// Continue button was tapped
    static func continueButtonTapped() -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "login.continue.tapped"
            )
        )
    }

    /// Login complete
    static func loginComplete() -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "login.login.complete"
            )
        )
    }

    /// Signup complete
    static func signupComplete() -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "login.signup.complete"
            )
        )
    }
}
