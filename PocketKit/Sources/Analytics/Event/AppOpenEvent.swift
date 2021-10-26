// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct AppOpenEvent: Event {
    public static let schema = "iglu:com.pocket/app_open/jsonschema/1-0-0"
    
    let secondsSinceLastOpen: UInt64?
    let secondsSinceLastBackground: UInt64?
    
    public init(secondsSinceLastOpen: UInt64?, secondsSinceLastBackground: UInt64?) {
        self.secondsSinceLastOpen = secondsSinceLastOpen
        self.secondsSinceLastBackground = secondsSinceLastBackground
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let secondsSinceLastOpen = secondsSinceLastOpen {
            try container.encode(secondsSinceLastOpen, forKey: .secondsSinceLastOpen)
        } else {
            try container.encodeNil(forKey: .secondsSinceLastOpen)
        }
        
        if let secondsSinceLastBackground = secondsSinceLastBackground {
            try container.encode(secondsSinceLastBackground, forKey: .secondsSinceLastBackground)
        } else {
            try container.encodeNil(forKey: .secondsSinceLastBackground)
        }
    }
}

private extension AppOpenEvent {
    enum CodingKeys: String, CodingKey {
        case secondsSinceLastOpen = "seconds_since_last_open"
        case secondsSinceLastBackground = "seconds_since_last_background"
    }
}
