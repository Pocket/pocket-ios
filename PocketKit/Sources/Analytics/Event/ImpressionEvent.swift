// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct ImpressionEvent: Event {
    public static let schema = "iglu:com.pocket/impression/jsonschema/1-0-1"
    
    let component: Component
    let requirement: Requirement
    
    public init(component: Component, requirement: Requirement) {
        self.component = component
        self.requirement = requirement
    }
}

extension ImpressionEvent {
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
