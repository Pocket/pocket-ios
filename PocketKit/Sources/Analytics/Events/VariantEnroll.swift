// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

/**
 * Event created when an app enrolls a user into a feature flag
 */
public struct VariantEnroll: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/variant_enroll/jsonschema/1-0-0"

    let featureFlagEntity: FeatureFlagEntity
    let uiEntity: UiEntity
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
        base.contexts.add(featureFlagEntity.toSelfDescribingJson())
        extraEntities.forEach { base.contexts.add($0.toSelfDescribingJson()) }

        return base
    }
}
