// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import class SnowplowTracker.SelfDescribing

/**
 * Event triggered when a user views a UI element.
 */
public struct Impression: Event {
    public static let schema = "iglu:com.pocket/impression/jsonschema/1-0-1"

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

    public init(component: Component, requirement: Requirement, uiEntity: UiEntity, extraEntities: [Entity]) {
        self.component = component
        self.requirement = requirement
        self.uiEntity = uiEntity
        self.extraEntities = extraEntities
    }

    public func toSelfDescribing() -> SelfDescribing {
        let base = SelfDescribing(schema: Engagement.schema, payload: [
            "component": NSString(string: component.rawValue),
            "requirement": NSString(string: requirement.rawValue),
        ])
        base.contexts.add(uiEntity.toSelfDescribingJson())
        extraEntities.forEach { base.contexts.add($0.toSelfDescribingJson()) }

        return base
    }
}

extension Impression {
    public enum Component: String, Encodable {
        case ui
        case card
        case content
        case screen
        case pushNotification

        enum CodingKeys: String, CodingKey {
            case ui
            case card
            case content
            case screen
            case pushNotification = "push_notification"
        }
    }

    public enum Requirement: String, Encodable {
        case instant
        case viewable
    }
}
