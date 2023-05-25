// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct Session: Codable, Equatable {
    public let guid: String
    public let accessToken: String
    public let userIdentifier: String

    public init(guid: String, accessToken: String, userIdentifier: String) {
        self.guid = guid
        self.accessToken = accessToken
        self.userIdentifier = userIdentifier
    }
}
