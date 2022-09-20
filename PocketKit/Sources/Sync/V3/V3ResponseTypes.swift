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

public struct RegisterPushTokenResponse: Decodable, BasicV3Response {
    var error: Int

    var status: Int

    /**
     The token that was registered
     */
    var token: String
}

public struct DeregisterPushTokenResponse: Decodable, BasicV3Response {
    var error: Int

    var status: Int
}
