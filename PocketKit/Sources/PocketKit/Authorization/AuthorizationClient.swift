// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AuthenticationServices
import Sync
import Adjust
import SharedPocketKit
import Localization

public class AuthorizationClient {
    typealias AuthenticationSessionFactory = (URL, String?, @escaping ASWebAuthenticationSession.CompletionHandler) -> AuthenticationSession

    private var isAuthenticating = false

    private let consumerKey: String
    private let adjustSignupEventToken: String
    private let authenticationSessionFactory: AuthenticationSessionFactory

    init(
        consumerKey: String,
        adjustSignupEventToken: String,
        authenticationSessionFactory: @escaping AuthenticationSessionFactory
    ) {
        self.consumerKey = consumerKey
        self.adjustSignupEventToken = adjustSignupEventToken
        self.authenticationSessionFactory = authenticationSessionFactory
    }

    @MainActor
    func logIn(from contextProvider: ASWebAuthenticationPresentationContextProviding?) async throws -> Response {
        defer { isAuthenticating = false }

        guard isAuthenticating == false else {
            throw AuthorizationClient.Error.alreadyAuthenticating
        }

        isAuthenticating = true
        return try await authenticate(with: "/login", contextProvider: contextProvider)
    }

    @MainActor
    func signUp(from contextProvider: ASWebAuthenticationPresentationContextProviding?) async throws -> Response {
        guard isAuthenticating == false else {
            throw AuthorizationClient.Error.alreadyAuthenticating
        }

        defer { isAuthenticating = false }

        isAuthenticating = true

        // This will only return if signup succeeds, otherwise
        // it will throw an error. We can await a successful
        // response and then track an adjust event.
        let response = try await authenticate(with: "/signup", contextProvider: contextProvider)

       Task { [weak self] in
           guard let self else {
               Log.capture(message: "weak self logging adjust")
               return
           }
          Adjust.trackEvent(ADJEvent(eventToken: self.adjustSignupEventToken))
       }

        return response
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
            URLQueryItem(name: "utm_source", value: "ios_next")
        ]

        guard let requestURL = components.url else {
            throw AuthorizationClient.Error.invalidComponents
        }

        return try await withCheckedThrowingContinuation { continuation in
            var session = authenticationSessionFactory(requestURL, requestRedirect) { url, error in
                if let error = error {
                    Log.breadcrumb(category: "auth", level: .error, message: "Error: \(error.localizedDescription) with url \(String(describing: url))")
                    continuation.resume(throwing: AuthorizationClient.Error.other(error))
                } else if let url = url {
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let guid = components.queryItems?.first(where: { $0.name == "guid" })?.value,
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

            Log.breadcrumb(category: "auth", level: .error, message: "User did log in")
        }
    }
}

extension AuthorizationClient {
    enum Error: LoggableError, Equatable {
        static func == (lhs: AuthorizationClient.Error, rhs: AuthorizationClient.Error) -> Bool {
            switch (lhs, rhs) {
            case (.invalidRedirect, .invalidRedirect):
                return true
            case (.alreadyAuthenticating, .alreadyAuthenticating):
                return true
            case (.other(let lhsError), .other(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }

        case invalidRedirect
        case invalidComponents
        case alreadyAuthenticating
        case other(Swift.Error)

        var logDescription: String {
            switch self {
            case .invalidRedirect:
                return Localization.couldNotSuccessfullyHandleTheServerRedirect
            case .invalidComponents:
                return Localization.couldNotGenerateCorrectURLForAuthentication
            case .alreadyAuthenticating:
                return Localization.authorizationClientIsAlreadyAuthenticating
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
