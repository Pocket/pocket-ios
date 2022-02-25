// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AuthenticationServices


private struct GUIDResponse: Decodable {
    let guid: String
}

public class AuthorizationClient {
    enum Error: Swift.Error {
        case invalidResponse
        case invalidSource
        case unexpectedRedirect
        case badRequest
        case invalidCredentials
        case serverError
        case unexpectedError
        case generic(Swift.Error)

        var localizedDescription: String {
            "Invalid email or password"
        }
    }

    enum Constants {
        static let baseURL = URL(
            string: ProcessInfo.processInfo.environment["POCKET_V3_BASE_URL"] ?? "https://getpocket.com"
        )!
    }

    private let consumerKey: String
    private let authenticationSession: AuthenticationSession.Type

    init(
        consumerKey: String,
        authenticationSession: AuthenticationSession.Type
    ) {
        self.consumerKey = consumerKey
        self.authenticationSession = authenticationSession
    }

    @MainActor
    func logIn(from contextProvider: ASWebAuthenticationPresentationContextProviding) async -> (Request?, Response?) {
        return await authenticate(with: "/login", contextProvider: contextProvider)
    }

    @MainActor
    func signUp(from contextProvider: ASWebAuthenticationPresentationContextProviding) async -> (Request?, Response?) {
        return await authenticate(with: "/signup", contextProvider: contextProvider)
    }

    @MainActor
    private func authenticate(with path: String, contextProvider: ASWebAuthenticationPresentationContextProviding) async -> (Request?, Response?) {
        guard var components = URLComponents(string: "https://getpocket.com") else {
            return (nil, nil)
        }

        let requestRedirect = "pocket"

        components.path = path
        components.queryItems = [
            URLQueryItem(name: "consumer_key", value: consumerKey),
            URLQueryItem(name: "redirect_uri", value: "\(requestRedirect)://fxa"),
            URLQueryItem(name: "utm_source", value: "ios")
        ]

        guard let requestURL = components.url else {
            return (nil, nil)
        }

        return await withCheckedContinuation { continuation in
            var session = authenticationSession.init(
                url: requestURL,
                callbackURLScheme: requestRedirect
            ) { url, error in
                let request = Request(url: requestURL, callbackURLScheme: requestRedirect)
                if error != nil {
                    continuation.resume(returning: (request, nil))
                } else if let url = url {
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value else {
                              continuation.resume(returning: (request, nil))
                        return
                    }

                    let guid = components.queryItems?.first(where: {$0.name == "guid" })?.value ?? ""
                    let userID = components.queryItems?.first(where: { $0.name == "id" })?.value ?? ""

                    let response = Response(guid: guid, accessToken: token, userIdentifier: userID)
                    continuation.resume(returning: (request, response))
                } else {
                    continuation.resume(returning: (request, nil))
                }
            }
            session.prefersEphemeralWebBrowserSession = true
            session.presentationContextProvider = contextProvider
            _ = session.start()
        }
    }
}

extension AuthorizationClient {
    struct Request {
        let url: URL
        let callbackURLScheme: String
    }

    struct Response {
        let guid: String
        let accessToken: String
        let userIdentifier: String
    }
}
