import Foundation
import Alamofire

/**
 Defines a router to be used against V3 for convience
 */
enum V3ClientRouter {
    case registerDeviceForPush(deviceIdentifier: String, pushType: String, token: String)
    case deregisterDeviceForPush(deviceIdentifier: String, pushType: String)

    /**
     The path for the endpoint function
     */
    var path: String {
        switch self {
        case .registerDeviceForPush:
            return "v3/push/register"
        case .deregisterDeviceForPush:
            return "v3/push/deregister"
        }
    }

    /**
     Which endpoint to use for the v3 call
     */
    var method: HTTPMethod {
        switch self {
        case .registerDeviceForPush:
            return .post
        case .deregisterDeviceForPush:
            return .post
        }
    }

    /**
     Convert our parameters for use on V3
     */
    var parameters: [String: String]? {
        switch self {
        case .registerDeviceForPush(let deviceIdentifier, let pushType, let token):
            return ["device_identifier": deviceIdentifier, "push_type": pushType, "token": token]
        case .deregisterDeviceForPush(let deviceIdentifier, let pushType):
            return ["device_identifier": deviceIdentifier, "push_type": pushType]
        }
    }
}

// MARK: - URLRequestConvertible
extension V3ClientRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        // TODO: Pull the base url from the environment
        let url = try "https://getpocket.com".asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        if method == .get {
            request = try URLEncodedFormParameterEncoder()
                .encode(parameters, into: request)
        } else if method == .post {
            request = try JSONParameterEncoder().encode(parameters, into: request)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        return request
    }
}
