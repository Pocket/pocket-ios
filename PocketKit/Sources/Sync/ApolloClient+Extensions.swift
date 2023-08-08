// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import ApolloAPI
import Foundation
import SharedPocketKit

extension ApolloClient {
    static func createDefault(
        sessionProvider: SessionProvider,
        consumerKey: String
    ) -> ApolloClient {
        let urlStringFromEnvironment = ProcessInfo.processInfo.environment["POCKET_CLIENT_API_URL"]
        let urlStringFromBundle = Bundle.main.infoDictionary?["PocketAPIBaseURL"] as? String
        let urlString = urlStringFromEnvironment ?? urlStringFromBundle ?? "https://api.getpocket.com/graphql"
        let url = URL(string: urlString)!

        let store = ApolloStore()

        return ApolloClient(
            networkTransport: RequestChainNetworkTransport(
                interceptorProvider: PrependingUnauthorizedInterceptorProvider(
                    prepend: AuthParamsInterceptor(
                        sessionProvider: sessionProvider,
                        consumerKey: consumerKey
                    ),
                    base: DefaultInterceptorProvider(store: store)
                ),
                endpointURL: url
            ),
            store: store
        )
    }
}

public protocol Session {
    var guid: String { get }
    var accessToken: String { get }
}

public protocol SessionProvider {
    var session: Session? { get }
}

public protocol AccessTokenProvider {
    var accessToken: String? { get }
}

private class AuthParamsInterceptor: ApolloInterceptor {
    private let sessionProvider: SessionProvider
    private let consumerKey: String

    init(
        sessionProvider: SessionProvider,
        consumerKey: String
    ) {
        self.sessionProvider = sessionProvider
        self.consumerKey = consumerKey
    }

    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: GraphQLOperation {
        request.graphQLEndpoint = appendAuthorizationQueryParameters(to: request.graphQLEndpoint)
        chain.proceedAsync(request: request, response: response, completion: completion)
    }

    private func appendAuthorizationQueryParameters(to url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            Log.capture(message: "Error - could not break Apollo url into components")
            return url
        }

        var items = components.queryItems ?? []
        items.append(contentsOf: [
            URLQueryItem(name: "consumer_key", value: consumerKey),
        ])

        if let session = sessionProvider.session {
            items.append(URLQueryItem(name: "guid", value: session.guid))
            items.append(URLQueryItem(name: "access_token", value: session.accessToken))
        } else {
            Log.capture(message: "Error - making PocketGraph request without auth")
        }

        components.queryItems = items

        return components.url ?? url
    }
}

private class PrependingUnauthorizedInterceptorProvider: InterceptorProvider {
    private let prepend: ApolloInterceptor
    private let base: InterceptorProvider

    init(
        prepend: ApolloInterceptor,
        base: InterceptorProvider
    ) {
        self.prepend = prepend
        self.base = base
    }

    func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation: GraphQLOperation {
        let base = base.interceptors(for: operation)
        return [prepend] + base
    }

    func additionalErrorInterceptor<Operation>(for operation: Operation) -> ApolloErrorInterceptor? where Operation: GraphQLOperation {
        // Utilize a custom interceptor to catch any status code errors, focusing on 401.
        return UnauthorizedErrorInterceptor()
    }
}

private class UnauthorizedErrorInterceptor: ApolloErrorInterceptor {
    func handleErrorAsync<Operation>(
        error: Error,
        chain: Apollo.RequestChain,
        request: Apollo.HTTPRequest<Operation>,
        response: Apollo.HTTPResponse<Operation>?,
        completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation: ApolloAPI.GraphQLOperation {
        // This case will be sent from a ResponseCodeInterceptor, which is a part of the base DefaultInterceptorProvider
        // that is used by our PrependingUnauthorizedInterceptorProvider. A 401 (Unauthorized) status code
        // will cause this error to be handled. We can capture it, and post a notification  to then log a user out.
        if case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(response: let errorResponse, rawData: _) = error,
           errorResponse?.statusCode == 401 {
            NotificationCenter.default.post(name: .unauthorizedResponse, object: nil)
        }

        // No matter the error, we want to bubble up the failure of the request.
        completion(.failure(error))
    }
}
