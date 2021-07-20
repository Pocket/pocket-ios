// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics


struct Impression: SnowplowEvent {
    static let schema = "iglu:com.pocket/impression/jsonschema/1-0-1"
    
    private let component: Component
    private let requirement: Requirement
    
    init(component: Component, requirement: Requirement) {
        self.component = component
        self.requirement = requirement
    }
}

extension Impression {
    enum Component: String, Encodable {
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
    
    enum Requirement: String, Encodable {
        case instant
        case viewable
    }
}
