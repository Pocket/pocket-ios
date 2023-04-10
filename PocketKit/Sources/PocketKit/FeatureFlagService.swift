// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Analytics
import Sync

/// Used to interact with the feature flags stored in our core data store
class FeatureFlagService {
    private let source: Source
    private let tracker: Tracker

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
    }

    /// Determine if a user is assigned to a test and a variant.
    func isAssigned(flag: String, variant: String = "control") -> Bool {
        guard let flag = source.fetchFeatureFlag(by: flag) else {
            // If we have no flag, the user is not assigned
            return false
        }
        let flagVariant = flag.variant ?? "control"

        return flag.assigned && flagVariant == variant
    }

    /// Only call this track feature when the User has felt the change of the feature flag, not before.
    func trackFeatureFlagFelt(flag: String, variant: String = "control") {
        tracker.track(event: Events.FeatureFlag.FeatureFlagFelt(name: flag, variant: variant))
    }

}
