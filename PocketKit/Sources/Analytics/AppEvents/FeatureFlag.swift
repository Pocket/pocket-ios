// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

public extension Events {
    struct FeatureFlag {}
}

public extension Events.FeatureFlag {
    /// Fired when a user feels a feature flag
    static func FeatureFlagFelt(name: String, variant: String) -> VariantEnroll {
        return VariantEnroll(
            featureFlagEntity: FeatureFlagEntity(
                name: name,
                variant: variant
            )
        )
    }
}
