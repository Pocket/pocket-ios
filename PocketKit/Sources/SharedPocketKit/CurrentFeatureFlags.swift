// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation

/// Describes the current feature flags that iOS cares about
public enum CurrentFeatureFlags: String, CaseIterable {
    case debugMenu = "perm.ios.debug.menu"
    case traceSampling = "perm.ios.sentry.traces"
    case profileSampling = "perm.ios.sentry.profile"
    case reportIssue = "perm.ios.report_issue"
    case disableReader = "perm.ios.disable_reader"
    case disableOnlineListen = "perm.ios.listen.disableOnline"
    case premiumSearchScopesExperiment = "EXPERIMENT_POCKET_PREMIUM_SEARCH_SCOPES"
    case bestOf20231PercentSticker = "BEST_OF_2023_1_PERCENT_STICKER"
    case bestOf20235PercentSticker = "BEST_OF_2023_5_PERCENT_STICKER"

    /// Description to use in a debug menu
    public var description: String {
        switch self {
        case .debugMenu:
            return "Debug menu for iOS"
        case .traceSampling:
            return "Percentage to use to sample traces in Sentry"
        case .profileSampling:
            return "Percentage to use to sample profiles in Sentry"
        case .reportIssue:
            return "Enable the Report an Issue feature when users encounter an error"
        case .disableReader:
            return "Disable the Reader to force use of a Web view for viewing content"
        case .disableOnlineListen:
            return "Disable online listen support, and fall back to offline TTS"
        case .premiumSearchScopesExperiment:
            return "Enable the search scopes experiment (for Premium users)"
        case .bestOf20231PercentSticker:
            return "User is part of the top 1 percent of Pocket readers"
        case .bestOf20235PercentSticker:
            return "User is part of the top 5 percent of Pocket readers"
        }
    }
}
