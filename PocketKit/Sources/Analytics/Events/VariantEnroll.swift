// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

/// Event triggered when an app enrolls a user in a test (details in “How to Implement A/B Test Analytics” in Analytics wiki). Entities included: always api_user, user, feature_flag; sometimes ui.
public struct VariantEnroll: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/variant_enroll/jsonschema/1-0-0"

    let featureFlagEntity: FeatureFlagEntity
    let extraEntities: [Entity]

    public init(featureFlagEntity: FeatureFlagEntity, extraEntities: [Entity] = []) {
        self.featureFlagEntity = featureFlagEntity
        self.extraEntities = extraEntities
    }

    public var description: String {
        self.featureFlagEntity.name
    }

    public func toSelfDescribing() -> SelfDescribing {
        let base = SelfDescribing(schema: ContentOpen.schema, payload: [:])
        base.entities.append(featureFlagEntity.toSelfDescribingJson())
        extraEntities.forEach { base.entities.append($0.toSelfDescribingJson()) }
        return base
    }
}
