import Foundation
import Alamofire

/**
 Client used to access Pocket's V3 endpoint which is legacy, but still holds some critical pieces of Pocket's API for now.
 */
class V3Client: NSObject {
    /**
     Our session we are keeping to use with Alamofire
     */
    let sessionManager: Alamofire.Session

    /**
     Our Request interceptors that are set up at initilization
     */
    let interceptors: Interceptor

    /**
     Init our V3Client using the current session provider and our consumer key
     */
    init(sessionProvider: SessionProvider,
         consumerKey: String
    ) {
        interceptors = Interceptor(interceptors: [
            V3RequestInterceptor(sessionProvider: sessionProvider, consumerKey: consumerKey)
        ])
        sessionManager = Alamofire.Session(
            configuration: URLSessionConfiguration.af.default,
            interceptor: interceptors
        )
    }

    // MARK: Push Notifications

    /**
     Used to register a Push Notification token with the v3 Pocket Backend, currently only used to enable Pocket's Intant Sync feature
     */
    func registerPushToken(for
                           deviceIdentifer: String,
                           pushType: String,
                           token: String
    ) async throws -> RegisterPushTokenResponse? {
        let dataTask = sessionManager.request(V3ClientRouter.registerDeviceForPush(
            deviceIdentifier: deviceIdentifer,
            pushType: pushType,
            token: token
        )).serializingDecodable(RegisterPushTokenResponse.self)

        let value = try await dataTask.value
        return value
    }

    /**
     Used to deregister a device with the v3 Pocket Backend, currently only used to deregister a device for Pocket's Instant Sync Feature
     */
    func deregisterPushToken(for
                             deviceIdentifer: String,
                             pushType: String
    ) async throws -> DeregisterPushTokenResponse? {
        let dataTask = sessionManager.request(V3ClientRouter.deregisterDeviceForPush(
            deviceIdentifier: deviceIdentifer,
            pushType: pushType
        )).serializingDecodable(DeregisterPushTokenResponse.self)

        let value = try await dataTask.value
        return value
    }
}

struct V3Error: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
