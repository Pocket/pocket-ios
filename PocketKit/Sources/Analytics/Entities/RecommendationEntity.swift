// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribingJson

public struct RecommendationEntity: Entity {
    public static let schema = "iglu:com.pocket/recommendation/jsonschema/1-0-0"

    let id: String
    let index: UIIndex

    public init(id: String, index: UIIndex) {
        self.id = id
        self.index = index
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        return SelfDescribingJson(schema: ReportEntity.schema, andDictionary: [
            "recommendation_id": self.id,
            "index": self.index,
        ])
    }
}
