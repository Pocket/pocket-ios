import Foundation

/**
 Client used to access Pocket's V3 endpoint which is legacy, but still holds some critical pieces of Pocket's API for now.
 */
public class V3Client: NSObject, V3ClientProtocol {

    /**
     V3 Client Error Types
     */
    enum Error: Swift.Error {
        case invalidResponse
        case invalidSource
        case unexpectedRedirect
        case badRequest
        case invalidCredentials
        case serverError
        case unexpectedError
        case generic(Swift.Error)
    }

    enum Constants {
        static let baseURL = URL(
            string: ProcessInfo.processInfo.environment["POCKET_V3_BASE_URL"] ?? "https://getpocket.com/v3"
        )!
    }

    /**
     Our http session we are keeping to reuse
     */
    let urlSession: URLSessionProtocol

    /**
     The session provider that holds the current session for the requests
     */
    let sessionProvider: SessionProvider

    /**
     Consumer key to use
     */
    let consumerKey: String

    public static func createDefault(
        sessionProvider: SessionProvider,
        consumerKey: String
    ) -> V3Client {
        let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
        return V3Client(sessionProvider: sessionProvider, consumerKey: consumerKey, urlSession: urlSession)
    }

    /**
     Init our V3Client using the current session provider and our consumer key
     */
    public init(
        sessionProvider: SessionProvider,
        consumerKey: String,
        urlSession: URLSessionProtocol
    ) {
        self.sessionProvider = sessionProvider
        self.consumerKey = consumerKey
        self.urlSession = urlSession
    }

    /**
     Helper function to execute a V3 request so we can re-use error responses and the type decoding.
     */
    func executeRequest<T>(
        request: URLRequest,
        decodable: T.Type
    )  async throws -> T  where T: Decodable {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request, delegate: nil)
        } catch {
            throw Error.generic(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.unexpectedError
        }

        // TODO: V3 almost always returns a 200 even when errors, so we will need to check the x-status-code header in the future
        switch httpResponse.statusCode {
        case 200...299:
            guard let source = httpResponse.value(forHTTPHeaderField: "X-Source"),
                  source == "Pocket" else {
                throw Error.invalidSource
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let response = try? decoder.decode(decodable, from: data) else {
                throw Error.invalidResponse
            }

            return response
        case 300...399:
            throw Error.unexpectedRedirect
        case 400:
            throw Error.badRequest
        case 401...499:
            throw Error.invalidCredentials
        case 500...599:
            throw Error.serverError
        default:
            throw Error.unexpectedError
        }
    }

    /**
     Given a path and parameters build a URL Request to be used on V3
     */
    func buildRequest(path: String, request: Encodable & V3Request)  throws -> URLRequest {
        let url = Constants.baseURL.appendingPathComponent(path)
        var builtRequest = URLRequest(url: url)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        builtRequest.httpBody = try! encoder.encode(request)
        builtRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        builtRequest.setValue("application/json", forHTTPHeaderField: "X-Accept")
        builtRequest.httpMethod = "POST"

        return builtRequest
    }
}

// MARK: Push Notifications

/**
 Extension for V3Client for push notifications
 */
extension V3Client {
    /**
     Used to register a Push Notification token with the v3 Pocket Backend, currently only used to enable Pocket's Intant Sync feature
     */
    public func registerPushToken(
        for deviceIdentifer: String,
        pushType: PushType,
        token: String
    ) async throws -> RegisterPushTokenResponse? {

        guard let guid = sessionProvider.session?.guid,
              let accessToken = sessionProvider.session?.accessToken else {
            throw Error.unexpectedError
        }

        let request = try buildRequest(
            path: "push/register",
            request: RegisterPushTokenRequest(
                accessToken: accessToken,
                consumerKey: consumerKey,
                guid: guid,
                deviceIdentifier: deviceIdentifer,
                pushType: pushType.rawValue,
                token: token
            )
        )

        return try await executeRequest(request: request, decodable: RegisterPushTokenResponse.self)
    }

    /**
     Used to deregister a device with the v3 Pocket Backend, currently only used to deregister a device for Pocket's Instant Sync Feature
     */
    public func deregisterPushToken(
        for deviceIdentifer: String,
        pushType: PushType
    ) async throws -> DeregisterPushTokenResponse? {
        guard let guid = sessionProvider.session?.guid,
              let accessToken = sessionProvider.session?.accessToken else {
            throw Error.unexpectedError
        }

        let request = try buildRequest(
            path: "push/deregister",
            request: DeregisterPushTokenRequest(
                accessToken: accessToken,
                consumerKey: consumerKey,
                guid: guid,
                deviceIdentifier: deviceIdentifer,
                pushType: pushType.rawValue
            )
        )

        return try await executeRequest(request: request, decodable: DeregisterPushTokenResponse.self)
    }
}
