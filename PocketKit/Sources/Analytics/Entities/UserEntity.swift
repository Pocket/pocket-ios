// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import class SnowplowTracker.SelfDescribingJson

public struct UserEntity: Entity {
    public static var schema = "iglu:com.pocket/user/jsonschema/1-0-0"

    let guid: String
    let userID: String

    public init(guid: String, userID: String) {
        self.guid = guid
        self.userID = userID
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        return SelfDescribingJson(schema: UserEntity.schema, andDictionary: [
            "hashed_guid": guid,
            "hashed_user_id": userID
        ])
    }
}
