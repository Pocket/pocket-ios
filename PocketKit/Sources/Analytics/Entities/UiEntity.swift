//
//  UiEntity.swift
//  
//
//  Created by Daniel Brooks on 2/9/23.
//

import Foundation
import class SnowplowTracker.SelfDescribingJson

public struct UiEntity: Entity, Encodable {
    public static let schema = "iglu:com.pocket/ui/jsonschema/1-0-3"

    let type: UiType
    let identifier: String
    let hierarchy: Int?
    let componentDetail: String?
    let index: Int?
    let label: Int?

    init(type: UiType, identifier: String, hierarchy: Int? = nil, componentDetail: String? = nil, index: Int? = nil, label: Int? = nil) {
        self.type = type
        self.identifier = identifier
        self.hierarchy = hierarchy
        self.componentDetail = componentDetail
        self.index = index
        self.label = label
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var data: [AnyHashable: Any] = [
            "type": type.rawValue,
            "identifier": identifier,
        ]

        if hierarchy != nil {
            data["hierarchy"] = hierarchy
        }

        if componentDetail != nil {
            data["component_detail"] = componentDetail
        }

        if index != nil {
            data["index"] = index
        }

        if label != nil {
            data["label"] = label
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
