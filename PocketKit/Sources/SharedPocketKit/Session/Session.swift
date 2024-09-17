// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct Session: Codable, Equatable, Sendable {
    public let guid: String
    public let accessToken: String
    public let userIdentifier: String

    public init(guid: String, accessToken: String, userIdentifier: String) {
        self.guid = guid
        self.accessToken = accessToken
        self.userIdentifier = userIdentifier
    }
}

extension Session {
    /// True if the session is anonymous
    public var isAnonymous: Bool {
        accessToken.isEmpty && userIdentifier.isEmpty
    }
    /// Instantiates an anonymous session, used for the signed out experience
    /// - Returns: a session with anonymous identifiers & tokens
    /// - Parameter guid: the anonymous session guid retrieved from the backend
    public static func anonymous(_ guid: String) -> Session {
        Session(guid: "", accessToken: "", userIdentifier: "")
    }
}
