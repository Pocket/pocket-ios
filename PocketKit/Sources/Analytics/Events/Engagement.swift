// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

public struct Engagement: Event {
    public static let schema = "iglu:com.pocket/engagement/jsonschema/1-0-1"

    /**
     * Indicates the type of engagement.
     */
    let type: Engagement.`Type`

    /**
     * The new value of a setting/filter, if the user engaged with something and modified its state in doing so.
     */
    let value: String?

    let uiEntity: UiEntity

    let extraEntities: [Entity]

    public init(_ type: Engagement.`Type` = .general, value: String? = nil, uiEntity: UiEntity, extraEntities: [Entity] = []) {
        self.type = type
        self.value = value
        self.uiEntity = uiEntity
        self.extraEntities = extraEntities
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

    public enum `Type` {
        case general
        case save(contentEntity: ContentEntity)
        case report(reportEntity: ReportEntity, contentEntity: ContentEntity)
        case dismiss

        struct `Type` {
            let value: String
            let requiredEntities: [Entity]
        }

        func toType() -> `Type` {
            switch self {
            case .general:
                return `Type`(value: "general", requiredEntities: [])
            case .save(let contentEntity):
                return `Type`(value: "save", requiredEntities: [contentEntity])
            case .report(let reportEntity, let contentEntity):
                return `Type`(value: "report", requiredEntities: [reportEntity, contentEntity])
            case .dismiss:
                return `Type`(value: "dismiss", requiredEntities: [])
            }
        }
    }
}
