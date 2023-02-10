//
//  UiEntity.swift
//  
//
//  Created by Daniel Brooks on 2/9/23.
//

import Foundation

public struct UiEntity: Entity {
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
}

private extension UiEntity {
    enum CodingKeys: String, CodingKey {
        case type
        case hierarchy
        case identifier
        case componentDetail = "component_detail"
        case index
        case label
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
