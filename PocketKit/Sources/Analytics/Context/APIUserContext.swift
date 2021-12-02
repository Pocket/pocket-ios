// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


public struct APIUserContext: Context {
    public static var schema = "iglu:com.pocket/api_user/jsonschema/1-0-1"
    
    let id: UInt
    let clientVersion: String
    
    public init(id: UInt, clientVersion: String) {
        self.id = id
        self.clientVersion = clientVersion
    }

    public init(consumerKey: String) {
        let components = consumerKey.components(separatedBy: "-")
        let id: UInt
        if let identifier = components.first, let apiID = UInt(identifier) {
            id = apiID
        } else {
            id = 1
        }

        let clientVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

        self.init(id: id, clientVersion: clientVersion)
    }
}

private extension APIUserContext {
    enum CodingKeys: String, CodingKey {
        case id = "api_id"
        case clientVersion = "client_version"
    }
}
