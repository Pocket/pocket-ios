protocol BasicV3Request {

    var accessToken: String? { get set }

    var consumerKey: String? { get set }

    var guid: String? { get set }

}

public struct RegisterPushTokenRequest: Codable, Equatable, BasicV3Request {
    var accessToken: String?

    var consumerKey: String?

    var guid: String?

    let deviceIdentifier: String
    let pushType: String
    let token: String
}

public struct DeregisterPushTokenRequest: Codable, Equatable, BasicV3Request {
    var accessToken: String?

    var consumerKey: String?

    var guid: String?

    let deviceIdentifier: String
    let pushType: String
}
