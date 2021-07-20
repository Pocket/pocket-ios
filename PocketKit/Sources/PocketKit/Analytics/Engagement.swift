// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics


enum EngagementType: String, Encodable {
    case general
    case save
    case report
    case dismiss
}

struct Engagement: SnowplowEvent {
    static let schema = "iglu:com.pocket/engagement/jsonschema/1-0-1"
    
    private let type: EngagementType
    private let value: String?
    
    init(type: EngagementType, value: String?) {
        self.type = type
        self.value = value
    }
}
