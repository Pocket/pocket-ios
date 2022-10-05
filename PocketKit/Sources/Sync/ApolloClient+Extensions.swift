// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import ApolloAPI
import Foundation

extension ApolloClient {
    static func createDefault(
        sessionProvider: SessionProvider,
        consumerKey: String
    ) -> ApolloClient {
        let urlStringFromEnvironment = ProcessInfo.processInfo.environment["POCKET_CLIENT_API_URL"]
        let urlStringFromBundle = Bundle.main.infoDictionary?["PocketAPIBaseURL"] as? String
        let urlString = urlStringFromEnvironment ?? urlStringFromBundle ?? "https://getpocket.com/graphql"
        let url = URL(string: urlString)!

        let store = ApolloStore()

        return ApolloClient(
            networkTransport: RequestChainNetworkTransport(
                interceptorProvider: PrependingInterceptorProvider(
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
            return url
        }

        var items = components.queryItems ?? []
        items.append(contentsOf: [
            URLQueryItem(name: "consumer_key", value: consumerKey),
        ])
        if let guid = sessionProvider.session?.guid {
            items.append(URLQueryItem(name: "guid", value: guid))
        }
        if let accessToken = sessionProvider.session?.accessToken {
            items.append(URLQueryItem(name: "access_token", value: accessToken))
        }
        components.queryItems = items

        return components.url ?? url
    }
}

private class PrependingInterceptorProvider: InterceptorProvider {
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
}
