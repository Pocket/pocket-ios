// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AuthenticationServices


public class AuthorizationClient {
    typealias AuthenticationSessionFactory = (URL, String?, @escaping ASWebAuthenticationSession.CompletionHandler) -> AuthenticationSession

    private let consumerKey: String
    private let authenticationSessionFactory: AuthenticationSessionFactory

    init(
        consumerKey: String,
        authenticationSessionFactory: @escaping AuthenticationSessionFactory
    ) {
        self.consumerKey = consumerKey
        self.authenticationSessionFactory = authenticationSessionFactory
    }

    @MainActor
    func logIn(from contextProvider: ASWebAuthenticationPresentationContextProviding?) async throws -> Response {
        return try await authenticate(with: "/login", contextProvider: contextProvider)
    }

    @MainActor
    func signUp(from contextProvider: ASWebAuthenticationPresentationContextProviding?) async throws -> Response {
        return try await authenticate(with: "/signup", contextProvider: contextProvider)
    }

    @MainActor
    private func authenticate(with path: String, contextProvider: ASWebAuthenticationPresentationContextProviding?) async throws -> Response {
        guard var components = URLComponents(string: "https://getpocket.com") else {
            throw AuthorizationClient.Error.invalidComponents
        }

        let requestRedirect = "pocket"

        components.path = path
        components.queryItems = [
            URLQueryItem(name: "consumer_key", value: consumerKey),
            URLQueryItem(name: "redirect_uri", value: "\(requestRedirect)://fxa"),
            URLQueryItem(name: "utm_source", value: "ios")
        ]

        guard let requestURL = components.url else {
            throw AuthorizationClient.Error.invalidComponents
        }

        return try await withCheckedThrowingContinuation { continuation in
            var session = authenticationSessionFactory(requestURL, requestRedirect) { url, error in
                if let error = error {
                    continuation.resume(throwing: AuthorizationClient.Error.other(error))
                } else if let url = url {
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let guid = components.queryItems?.first(where: {$0.name == "guid" })?.value,
                          let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value,
                          let userID = components.queryItems?.first(where: { $0.name == "id" })?.value else {
                              continuation.resume(throwing: AuthorizationClient.Error.invalidRedirect)
                        return
                    }

                    let response = Response(guid: guid, accessToken: token, userIdentifier: userID)
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: AuthorizationClient.Error.invalidRedirect)
                }
            }
            session.prefersEphemeralWebBrowserSession = true
            session.presentationContextProvider = contextProvider
            _ = session.start()
        }
    }
}

extension AuthorizationClient {
    enum Error: LocalizedError, Equatable {
        static func ==(lhs: AuthorizationClient.Error, rhs: AuthorizationClient.Error) -> Bool {
            switch (lhs, rhs) {
            case (.invalidRedirect, .invalidRedirect):
                return true
            case (.other(let lhsError), .other(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }

        case invalidRedirect
        case invalidComponents
        case other(Swift.Error)

        var errorDescription: String? {
            switch self {
            case .invalidRedirect:
                return "Could not successfully handle the server redirect."
            case .invalidComponents:
                return "Could not generate correct URL for authentication."
            case .other(let error):
                return error.localizedDescription
            }
        }
    }

    struct Response {
        let guid: String
        let accessToken: String
        let userIdentifier: String
    }
}
