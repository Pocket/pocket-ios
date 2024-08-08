// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Events {
    struct SignedOut {}
}

public extension Events.SignedOut {
    enum LoginSource: String {
        case onboarding
        case homeBanner
        case recommendationCard
        case collection
        case collectionStory
        case syndicatedArticle
        case emptySavesButton
        case savesFilter
        case savesAddUrl
        case settingsSignin
    }
}

public extension Events.SignedOut {
    /// Sign up or sign in banner viewed
    /// - Returns: the impression event
    static func signinBannerImpression() -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "home.signin.banner.impression"
            )
        )
    }
    /// Authentication was requested
    /// - Parameter loginSource: the source where the authentication was requested from
    /// - Returns: The associated engagement event
    static func authenticationRequested(_ loginSource: LoginSource?) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "signedOut.authentication.requested",
                componentDetail: loginSource?.rawValue ?? ""
            )
        )
    }
}
