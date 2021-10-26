// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct UserContext: Context {
    public static let schema = "iglu:com.pocket/user/jsonschema/1-0-0"
    
    let guid: String
    let userID: String
    
    public init(guid: String, userID: String) {
        self.guid = guid
        self.userID = userID
    }
}

extension UserContext {
    enum CodingKeys: String, CodingKey {
        case guid = "hashed_guid"
        case userID = "hashed_user_id"
    }
}
