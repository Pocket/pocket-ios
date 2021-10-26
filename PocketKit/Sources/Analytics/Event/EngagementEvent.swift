// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public enum EngagementEvent: String, Encodable {
    case general
    case save
    case report
    case dismiss
}

public struct SnowplowEngagement: Event {
    public static let schema = "iglu:com.pocket/engagement/jsonschema/1-0-1"
    
    let type: EngagementEvent
    let value: String?
    
    public init(type: EngagementEvent, value: String?) {
        self.type = type
        self.value = value
    }
}
