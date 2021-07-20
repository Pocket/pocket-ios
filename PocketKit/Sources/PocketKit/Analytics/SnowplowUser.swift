// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics


struct SnowplowUser: SnowplowContext {
    static let schema = "iglu:com.pocket/user/jsonschema/1-0-0"
    
    let guid: String
    let userID: String
}

extension SnowplowUser {
    enum CodingKeys: String, CodingKey {
        case guid = "hashed_guid"
        case userID = "hashed_user_id"
    }
}
