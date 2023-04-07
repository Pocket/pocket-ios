// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import class SnowplowTracker.SelfDescribingJson

/// Entity to describe a feature flag, or test/experiment. Expected to be included with any `variant_enroll` event.
public struct FeatureFlagEntity: Entity {
    public static var schema = "iglu:com.pocket/feature_flag/jsonschema/1-0-1"

    /// The name of the feature flag, or test/experiment.
    let name: String

    /// The name of the feature flag / test variant. Each feature flag should always include a 'control' variant.
    let variant: String

    public init(name: String, variant: String) {
        self.name = name
        self.variant = variant
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        return SelfDescribingJson(schema: FeatureFlagEntity.schema, andDictionary: [
            "name": name,
            "variant": variant
        ])
    }
}
