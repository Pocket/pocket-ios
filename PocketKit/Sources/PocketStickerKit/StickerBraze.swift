// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BrazeKit
import SharedPocketKit
import Sync

/**
 Class that is managing our Braze SDK implementation for the Sticker extension
 */
class StickerBraze: NSObject {
    /// Our Braze SDK Object
    let braze: Braze

    init(apiKey: String, endpoint: String, groupdID: String) {
        // Init Braze with our information.
        let configuration = Braze.Configuration(
            apiKey: apiKey,
            endpoint: endpoint
        )

        // Enable logging of general SDK information (e.g. user changes, etc.)
        configuration.logger.level = .info
        configuration.push.appGroup = groupdID
        braze = Braze(configuration: configuration)

        super.init()
    }
}

/**
 Conforming to our PocketBraze Protocol
 */
extension StickerBraze {
    func isFeatureFlagEnabled(flag: CurrentFeatureFlags) -> Bool {
        guard let featureFlag = braze.featureFlags.featureFlag(id: flag.rawValue) else {
            return false
        }

        return featureFlag.enabled
    }

    func loggedIn(session: SharedPocketKit.Session) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Braze SDK docs say this needs to be called from the main thread.
            // https://www.braze.com/docs/developer_guide/platform_integration_guides/ios/analytics/setting_user_ids/#assigning-a-user-id
            braze.changeUser(userId: session.userIdentifier)

            // Request refresh of feature flags when user is initially signed in
            braze.featureFlags.requestRefresh()
        }
    }

    func loggedOut(session: SharedPocketKit.Session?) {
        // Waiting on braze support to understand logout
    }

    /// Logs a feature flag impression by Braze, selectively if the feature flag is being enabled by Braze
    /// - Parameter id: The id of the feature flag
    /// - Returns: True if the feature flag impression was logged by Braze, otherwise false
    func logFeatureFlagImpression(flag: CurrentFeatureFlags) -> Bool {
        let shouldLog = switch flag {
        case .premiumSearchScopesExperiment, .bestOf20231PercentSticker, .bestOf20235PercentSticker:
            true
        default:
            false
        }

        if shouldLog {
            braze.featureFlags.logFeatureFlagImpression(id: flag.rawValue)
        }
        return shouldLog
    }
}
