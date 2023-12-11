// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import class SnowplowTracker.SelfDescribing

/**
 * Event triggered when a user views a UI element.
 */
public struct Impression: Event, CustomStringConvertible {
    public static let schema = "iglu:com.pocket/impression/jsonschema/1-0-2"

    /**
     * Indicator of the component that is being viewed.
     */
    let component: Component

    /**
     * Indicates the requirement before an impression can be triggered (instant: any
     * pixel displayed on screen; viewable: +50% of component displayed for 1+ seconds).
     */
    let requirement: Requirement

    let uiEntity: UiEntity

    let extraEntities: [Entity]

    public init(component: Component, requirement: Requirement, uiEntity: UiEntity, extraEntities: [Entity] = []) {
        self.component = component
        self.requirement = requirement
        self.uiEntity = uiEntity
        self.extraEntities = extraEntities
    }

    public func toSelfDescribing() -> SelfDescribing {
        let componentValue = component.toComponent()

        let base = SelfDescribing(schema: Impression.schema, payload: [
            "component": componentValue.value,
            "requirement": requirement.rawValue,
        ])
        base.entities.append(uiEntity.toSelfDescribingJson())
        extraEntities.forEach { base.entities.append($0.toSelfDescribingJson()) }
        componentValue.requiredEntities.forEach { base.entities.append($0.toSelfDescribingJson()) }

        return base
    }

    public var description: String {
        self.uiEntity.identifier
    }
}

extension Impression {
    public enum Component {
        struct Component {
            let value: String
            let requiredEntities: [Entity]
        }

        case ui
        case card
        case content(contentEntity: ContentEntity)
        case screen
        case pushNotification
        case button

        func toComponent() -> Component {
            switch self {
            case .ui:
                return Component(value: "ui", requiredEntities: [])
            case .card:
                return Component(value: "card", requiredEntities: [])
            case .content(let contentEntity):
                return Component(value: "content", requiredEntities: [contentEntity])
            case .screen:
                return Component(value: "screen", requiredEntities: [])
            case .pushNotification:
                return Component(value: "push_notification", requiredEntities: [])
            case .button:
                return Component(value: "button", requiredEntities: [])
            }
        }
    }

    public enum Requirement: String, Encodable {
        case instant // An impression triggered when a UI element is loaded by the app, but not guaranteed to be viewed by the user
        case viewable // An impression triggered as soon as any pixel of that UI element is visible for any length of time
    }
}
