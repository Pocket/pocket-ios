import Foundation

/**
 Enum representing the Push types that are available in V3
 */
public enum PushType: String {
    /**
     Alpha Neue bundle identifier, Sandbox APNS
     */
    case alphadev

    /**
     Alpha Neue bundle identifier, Production APNS
     */
    case alpha

    /**
     Readitlater bundle identifier, Sandbox APNS
     */
    case proddev

    /**
     Readitlater bundle identifier, Production APNS
     */
    case prod
}

/**
 Protocol used to define our V3Client, this is used to be able to create different underlying
 */
public protocol V3ClientProtocol {
    /**
     Used to register a Push Notification token with the v3 Pocket Backend, currently only used to enable Pocket's Intant Sync feature
     */
    func registerPushToken(
        for  deviceIdentifer: String,
        pushType: PushType,
        token: String,
        session: Session
    ) async throws -> RegisterPushTokenResponse?

    /**
     Used to deregister a device with the v3 Pocket Backend, currently only used to deregister a device for Pocket's Instant Sync Feature
     */
    func deregisterPushToken(
        for deviceIdentifer: String,
        pushType: PushType,
        session: Session
    ) async throws -> DeregisterPushTokenResponse?

    /**
     - Returns: PremiumStatusResponse
     */
    func premiumStatus() async throws -> PremiumStatusResponse
}
