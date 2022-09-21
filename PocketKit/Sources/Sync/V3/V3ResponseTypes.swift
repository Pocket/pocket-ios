import Foundation

protocol BasicV3Response {
    /**
     Usally 1 if error, but can be other values to indicate an error code
     */
    var error: Int { get set }

    /**
     A 0/1 value which could mean true/false
     */
    var status: Int { get set }
}

public struct V3DeviceToken: Decodable {
    /**
     The deviceIdentifier that was registered
     */
    var deviceIdentifier: String

    /**
     Timestamp of when the token from apple expires
     */
    var expiresAt: Int
}

// MARK: Push Notifications
public struct RegisterPushTokenResponse: Decodable, BasicV3Response {
    var error: Int

    var status: Int

    var token: V3DeviceToken
}

public struct DeregisterPushTokenResponse: Decodable, BasicV3Response {
    var error: Int

    var status: Int
}
