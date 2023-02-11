// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribingJson

public struct ReportEntity: OldEntity, Entity {
    public static let schema = "iglu:com.pocket/report/jsonschema/1-0-0"

    let reason: Reason
    let comment: String?

    public init(reason: Reason, comment: String? = nil) {
        self.reason = reason
        self.comment = comment
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var data: [AnyHashable: Any] = [
            "reason": reason.rawValue,
        ]

        if comment != nil {
            data["comment"] = comment
        }

        return SelfDescribingJson(schema: ReportEntity.schema, andDictionary: data)
    }
}

extension ReportEntity {
    public enum Reason: String, CaseIterable, Encodable {
        case brokenMeta = "broken_meta"
        case wrongCategory = "wrong_category"
        case sexuallyExplicit = "sexually_explicit"
        case offensive
        case misinformation
        case other
    }
}
