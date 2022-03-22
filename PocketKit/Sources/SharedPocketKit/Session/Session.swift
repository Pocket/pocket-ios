import Foundation


public struct Session: Codable {
    public let guid: String
    public let accessToken: String
    public let userIdentifier: String

    public init(guid: String, accessToken: String, userIdentifier: String) {
        self.guid = guid
        self.accessToken = accessToken
        self.userIdentifier = userIdentifier
    }
}
