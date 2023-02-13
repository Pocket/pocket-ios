//
//  UiEntity.swift
//
//
//  Created by Daniel Brooks on 2/9/23.
//
import Foundation
import class SnowplowTracker.SelfDescribingJson

/**
 * Entity to describe a front-end user interface. Should be included with any
 * impression, engagement, or custom engagement events.
 */
public struct UiEntity: Entity {
    public static let schema = "iglu:com.pocket/ui/jsonschema/1-0-3"

    /**
     * The general UI component type.
     */
    let type: UiType

    /**
     * The detailed type of UI component (e.g. standard, radio, checkbox, etc).
     */
    let componentDetail: String?

    /**
     * The internal name for the specific UI.  The general pattern for naming events is
     * screen.feature.drilldown.action
     * This is a guideline, not a hard rule.
     * And example:
     * home.recentsaves.save.delete
     * https://docs.google.com/spreadsheets/d/10DrvRWaRjHbhvdoetVqeScK452alaSUtXpgdLGtEs3A/edit#gid=778876482
     */
    let identifier: String

    /**
     * The zero-based index value of a UI, if found in a list of similar UI components (e.g. item in a feed).
     */
    let index: Int?

    /**
     * The en-US display name for the UI, if available.
     */
    let label: String?

    /**
     * The state of a UI element before the engagement (e.g. the initial value for a setting or filter).
     */
    let value: String?

    init(_ type: UiType, identifier: String, componentDetail: String? = nil, index: Int? = nil, label: String? = nil, value: String? = nil) {
        self.type = type
        self.identifier = identifier
        self.componentDetail = componentDetail
        self.index = index
        self.label = label
        self.value = value
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var data: [AnyHashable: Any] = [
            "type": type.rawValue,
            "identifier": identifier,
        ]

        if componentDetail != nil {
            data["component_detail"] = componentDetail
        }

        if index != nil {
            data["index"] = index
        }

        if label != nil {
            data["label"] = label
        }

        if value != nil {
            data["value"] = label
        }

        return SelfDescribingJson(schema: UiEntity.schema, andDictionary: data)
    }
}

extension UiEntity {
    public enum UiType: String, Encodable {
        case button
        case dialog
        case menu
        case card
        case list
        case reader
        case page
        case screen
        case link
        case pushNotification = "push_notification"
    }
}
