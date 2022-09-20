import Foundation
import Alamofire

/**
 Custom class to provide V3 authentication
 */
class V3RequestInterceptor: RequestInterceptor {

    /**
     The provider that will contain the active session for us to get credentials from
     */
    private let sessionProvider: SessionProvider

    /**
     The active session consumer key
     */
    private let consumerKey: String

    /**
     Set a limit for how many times Alamofire should retry requests
     */
    let retryLimit = 5

    /**
     Set a delay for how long we should wait to retry a request
     */
    let retryDelay: TimeInterval = 10

    init(
        sessionProvider: SessionProvider,
        consumerKey: String
    ) {
        self.sessionProvider = sessionProvider
        self.consumerKey = consumerKey
    }

    /**
     Intercept the request and add the default V3 authentication parameters
     */
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

        var parameters = [
            "consumer_key": consumerKey
        ]

        guard let session = sessionProvider.session else {
            // We have no session so we need to call failure
            completion(.failure(V3Error("No session available when executing against V3")))
            return
        }

        // Add session parameters
        parameters["access_token"] = session.accessToken
        parameters["guid"] = session.guid

        // Make request manipulatable.
        var urlRequest = urlRequest

        do {
            if urlRequest.method == .get {
                urlRequest = try URLEncodedFormParameterEncoder()
                    .encode(parameters, into: urlRequest)
            } else if urlRequest.method == .post {
                urlRequest = try JSONParameterEncoder().encode(parameters, into: urlRequest)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
        } catch {
            completion(.failure(error))
            return
        }

        completion(.success(urlRequest))
    }

    /**
     Intercept retry requests to insert our retry parameters.
     */
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        // Retry for 5xx status codes
        if
            let statusCode = response?.statusCode,
            (500...599).contains(statusCode),
            request.retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        } else {
            return completion(.doNotRetry)
        }
    }
}
