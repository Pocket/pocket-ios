// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribingJson

/**
 * Entity to describe a slate of recommendations. Should be included with any
 * impression or engagement events with recommendations.
 */
public struct SlateEntity: Entity {
    public static let schema = "iglu:com.pocket/slate/jsonschema/1-0-0"

    /**
     * A unique slug/id that is used to identify a slate and its specific configuration.
     */
    let id: String

    /**
     * A guid that is unique to every API request that returns slates.
     */
    let requestID: String

    /**
     * A string identifier of a recommendation experiment.
     */
    let experiment: String

    /**
     * The zero-based index value of the slate’s display position among other slates in the same lineup.
     */
    let index: Int

    /**
     * The name to show the user for a slate.
     */
    let displayName: String?

    /**
     * The description of the slate.
     */
    let description: String?

    public init(id: String, requestID: String, experiment: String, index: Int, displayName: String? = nil, description: String? = nil) {
        self.id = id
        self.requestID = requestID
        self.experiment = experiment
        self.index = index
        self.displayName = displayName
        self.description = description
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var data: [AnyHashable: Any] = [
            "slate_id": id,
            "request_id": requestID,
            "experiment": experiment,
            "index": index
        ]

        if displayName != nil {
            data["display_name"] = displayName
        }

        if description != nil {
            data["description"] = description
        }

        return SelfDescribingJson(schema: SlateEntity.schema, andDictionary: data)
    }
}
