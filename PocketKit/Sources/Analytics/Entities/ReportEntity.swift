// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribingJson

/**
 * Entity for a flag from a user to Pocket that an item is inappropriate or broken.
 * Should be included with any engagement event where type = report.
 */
public struct ReportEntity: Entity {
    public static let schema = "iglu:com.pocket/report/jsonschema/1-0-0"

    /**
     * The reason for the report selected from a list of options.
     */
    let reason: Reason

    /**
     * An optional user-provided comment on the reason for the report.
     */
    let comment: String?

    public init(reason: Reason, comment: String? = nil) {
        self.reason = reason
        self.comment = comment
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var data: [String: Any] = [
            "reason": reason.rawValue,
        ]

        if let comment {
            data["comment"] = comment
        }

        return SelfDescribingJson(schema: ReportEntity.schema, andDictionary: data)
    }
}

extension ReportEntity {
    public enum Reason: String, CaseIterable, Encodable, Sendable {
        case brokenMeta = "broken_meta"
        case wrongCategory = "wrong_category"
        case sexuallyExplicit = "sexually_explicit"
        case offensive
        case misinformation
        case other
    }
}
