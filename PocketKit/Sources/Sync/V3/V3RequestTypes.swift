protocol V3Request: Encodable {
    var accessToken: String { get }

    var consumerKey: String { get }

    var guid: String { get }

}

public struct RegisterPushTokenRequest: Codable, Equatable, V3Request {
    let accessToken: String

    let consumerKey: String

    let guid: String

    let deviceIdentifier: String
    let pushType: String
    let token: String
}

public struct DeregisterPushTokenRequest: Codable, Equatable, V3Request {
    let accessToken: String

    let consumerKey: String

    let guid: String

    let deviceIdentifier: String
    let pushType: String
}
