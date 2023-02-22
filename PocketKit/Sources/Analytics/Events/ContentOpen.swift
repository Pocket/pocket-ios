// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribing
import Foundation

/**
 * Event created when an app initiates the opening a piece of content
 * (triggered by the intent to open an item and does not guarantee that the item was viewed).
 */
public struct ContentOpen: Event {
    public static let schema = "iglu:com.pocket/content_open/jsonschema/1-0-0"

    /**
     * Indicates whether the content is being opened within a
     * Pocket property (internal) or offsite / in another app (external
     */
    let destination: Destination

    /**
     * Indicates whether content was opened with direct intent
     * (e.g. user taps vs. next-up in Listen playlist or infinite scroll
     */
    let trigger: Trigger

    let contentEntity: ContentEntity
    let uiEntity: UiEntity
    let extraEntities: [Entity]

    public init(destination: Destination = .internal, trigger: Trigger = .click, contentEntity: ContentEntity, uiEntity: UiEntity, extraEntities: [Entity] = []) {
        self.destination = destination
        self.trigger = trigger
        self.contentEntity = contentEntity
        self.uiEntity = uiEntity
        self.extraEntities = extraEntities
    }

    public func toSelfDescribing() -> SelfDescribing {
        let base = SelfDescribing(schema: ContentOpen.schema, payload: [
            "destination": NSString(string: destination.rawValue),
            "trigger": NSString(string: trigger.rawValue),
        ])
        base.contexts.add(uiEntity.toSelfDescribingJson())
        base.contexts.add(contentEntity.toSelfDescribingJson())
        extraEntities.forEach { base.contexts.add($0.toSelfDescribingJson()) }

        return base
    }
}

extension ContentOpen {
    public enum Destination: String, Encodable {
        case `internal`
        case external
    }

    public enum Trigger: String, Encodable {
        case click
        case auto
    }
}
