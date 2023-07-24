// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Analytics
import Sync

protocol FeatureFlagServiceProtocol {
    /// Determine if a user is assigned to a test and a variant.
    func isAssigned(flag: CurrentFeatureFlags, variant: String?) -> Bool

    /// Only call this track feature when the User has felt the change of the feature flag, not before.
    func trackFeatureFlagFelt(flag: CurrentFeatureFlags, variant: String?)

    func getPayload(flag: CurrentFeatureFlags) -> String?

    var shouldDisableReader: Bool { get }
}

/// Extension for default values https://medium.com/@georgetsifrikas/swift-protocols-with-default-values-b7278d3eef22
extension FeatureFlagServiceProtocol {
    func isAssigned(flag: CurrentFeatureFlags, variant: String? = "control") -> Bool {
        return isAssigned(flag: flag, variant: variant)
    }

    func trackFeatureFlagFelt(flag: CurrentFeatureFlags, variant: String? = "control") {
        return trackFeatureFlagFelt(flag: flag, variant: variant)
    }
}

/// Used to interact with the feature flags stored in our core data store
class FeatureFlagService: FeatureFlagServiceProtocol {
    private let source: Source
    private let tracker: Tracker
    private let userDefaults: UserDefaults

    init(source: Source, tracker: Tracker, userDefaults: UserDefaults) {
        self.source = source
        self.tracker = tracker
        self.userDefaults = userDefaults
    }

    var shouldDisableReader: Bool {
        isAssigned(flag: .disableReader) || userDefaults.bool(forKey: UserDefaults.Key.toggleOriginalView)
    }

    /// Determine if a user is assigned to a test and a variant.
    func isAssigned(flag: CurrentFeatureFlags, variant: String?) -> Bool {
        guard let flag = source.fetchFeatureFlag(by: flag.rawValue), let variant else {
            // If we have no flag, the user is not assigned or we have no control value
            return false
        }
        let flagVariant = flag.variant ?? "control"

        return flag.assigned && flagVariant == variant
    }

    func getPayload(flag: CurrentFeatureFlags) -> String? {
        guard let flag = source.fetchFeatureFlag(by: flag.rawValue) else {
            return nil
        }

        return flag.payloadValue
    }

    /// Only call this track feature when the User has felt the change of the feature flag, not before.
    func trackFeatureFlagFelt(flag: CurrentFeatureFlags, variant: String?) {
        guard let variant else {
            // No variant value so we can't do anything
            return
        }
        tracker.track(event: Events.FeatureFlag.FeatureFlagFelt(name: flag.rawValue, variant: variant))
    }
}

/// Describes the current feature flags that iOS cares about
public enum CurrentFeatureFlags: String, CaseIterable {
    case listen = "temp.ios.listen"
    case listenTagsPlaylists = "temp.ios.listen.tag_playlists"
    case debugMenu = "perm.ios.debug.menu"
    case traceSampling = "perm.ios.sentry.traces"
    case profileSampling = "perm.ios.sentry.profile"
    case reportIssue = "perm.ios.report_issue"
    case disableReader = "perm.ios.disable_reader"
    case nativeCollections = "perm.ios.native_collections"

    /// Description to use in a debug menu
    var description: String {
        switch self {
        case .listen:
            return "Enable the Listen feature"
        case .listenTagsPlaylists:
            return "Enable the Playlist support via tags in Listen"
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
        case .nativeCollections:
            return "Enable native collections instead of opening collections in web view"
        }
    }
}
