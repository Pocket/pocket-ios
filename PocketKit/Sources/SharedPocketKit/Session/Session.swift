// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct Session: Codable, Equatable, Sendable {
    public let guid: String
    public let accessToken: String
    public let userIdentifier: String
    public let sessionType: SessionType

    public init(guid: String, accessToken: String, userIdentifier: String, sessionType: SessionType = .authenticated) {
        self.guid = guid
        self.accessToken = accessToken
        self.userIdentifier = userIdentifier
        self.sessionType = sessionType
    }
}

extension Session {
    public enum SessionType: String, Codable, Sendable {
        case authenticated
        case anonymous
    }

    /// True if the session is anonymous
    public var isAnonymous: Bool {
        sessionType == .anonymous
    }
    /// Instantiates an anonymous session, used for the signed out experience
    /// - Returns: a session with anonymous identifiers & tokens
    public static func anonymous() -> Session {
        Session(guid: "", accessToken: "", userIdentifier: "", sessionType: .anonymous)
    }
}
