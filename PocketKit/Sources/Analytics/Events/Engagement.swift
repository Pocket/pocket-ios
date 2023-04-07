// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import class SnowplowTracker.SelfDescribing

/**
 * Event triggered when a user engages with a UI element.
 */
public struct Engagement: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/engagement/jsonschema/1-0-1"

    /**
     * Indicates the type of engagement.
     */
    let type: Engagement.EngagementType

    /**
     * The new value of a setting/filter, if the user engaged with something and modified its state in doing so.
     */
    let value: String?

    let uiEntity: UiEntity

    let extraEntities: [Entity]

    public init(_ type: Engagement.EngagementType = .general, value: String? = nil, uiEntity: UiEntity, extraEntities: [Entity] = []) {
        self.type = type
        self.value = value
        self.uiEntity = uiEntity
        self.extraEntities = extraEntities
    }

    public var description: String {
        self.uiEntity.identifier
    }

    public func toSelfDescribing() -> SelfDescribing {
        var payload: [String: NSObject] = [
            "type": NSString(string: type.toType().value),
        ]

        if let value = value {
            payload["value"] = NSString(string: value)
        }

        let base = SelfDescribing(schema: Engagement.schema, payload: payload)
        base.contexts.add(uiEntity.toSelfDescribingJson())
        extraEntities.forEach { base.contexts.add($0.toSelfDescribingJson()) }
        type.toType().requiredEntities.forEach { base.contexts.add($0.toSelfDescribingJson()) }

        return base
    }

    public enum EngagementType {
        case general
        case save(contentEntity: ContentEntity)
        case report(reportEntity: ReportEntity, contentEntity: ContentEntity)
        case dismiss

        struct EngagementType {
            let value: String
            let requiredEntities: [Entity]
        }

        func toType() -> EngagementType {
            switch self {
            case .general:
                return EngagementType(value: "general", requiredEntities: [])
            case .save(let contentEntity):
                return EngagementType(value: "save", requiredEntities: [contentEntity])
            case .report(let reportEntity, let contentEntity):
                return EngagementType(value: "report", requiredEntities: [reportEntity, contentEntity])
            case .dismiss:
                return EngagementType(value: "dismiss", requiredEntities: [])
            }
        }
    }
}
