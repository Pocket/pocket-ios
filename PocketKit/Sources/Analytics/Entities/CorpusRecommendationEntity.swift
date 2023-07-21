// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribingJson

public struct CorpusRecommendationEntity: Entity {
    public static let schema = "iglu:com.pocket/recommendation/jsonschema/1-0-0"

    let id: String

    public init(id: String) {
        self.id = id
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        return SelfDescribingJson(schema: CorpusRecommendationEntity.schema, andDictionary: [
            "corpus_recommendation_id": self.id,
        ])
    }
}
