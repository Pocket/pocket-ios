// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AuthenticationServices
import SharedPocketKit

@MainActor
final class Authenticator: NSObject, ObservableObject {
    enum State {
        case error(Error)
        case ready
    }

    var contextProvider: ASWebAuthenticationPresentationContextProviding?
    private let authorizationClient: AuthorizationClient
    private let appSession: AppSession
    @Published var authenticationState: State = .ready

    init(authorizationClient: AuthorizationClient, appSession: AppSession) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        super.init()
        self.contextProvider = self
    }

    func authenticate() {
        Task { [weak self] in
            guard let self else {
                return
            }
            await self.parseResponse(self.authorizationClient.authenticate)
        }
    }

    func anonymousAccess() {
        appSession.currentSession = Session.anonymous()
        NotificationCenter.default.post(name: .anonymousAccess, object: appSession.currentSession)
        authenticationState = .ready
    }

    private func parseResponse(_ authentication: (ASWebAuthenticationPresentationContextProviding?) async throws -> AuthorizationClient.Response) async {
        do {
            // TODO: CONCURRENCY - Need to figure out how to handle ASWebAuthenticationPresentationContextProviding and other native non-sendable types
            let response = try await authentication(contextProvider)
            handle(response)
        } catch {
            // AuthorizationClient should only ever throw an AuthorizationClient.error
            guard let error = error as? AuthorizationClient.Error else {
                Log.capture(error: error)
                return
            }

            switch error {
            case .invalidRedirect, .invalidComponents:
                // If component generation failed, we should alert the user (to hopefully reach out),
                // as well as capture the error
                authenticationState = .error(error)
                Log.capture(error: error)
            case .alreadyAuthenticating:
                Log.capture(error: error)
            case .other(let nested):
                // All other errors will be throws by the AuthenticationSession,
                // which in production will be ASWebAuthenticationSessionError.
                // However, capture any other errors (if one exists)
                if let nested = nested as? ASWebAuthenticationSessionError {
                    // We can ignore the "error" if a user has cancelled authentication,
                    // but the other errors should never occur, so they should be captured.
                    switch nested.code {
                    case .presentationContextInvalid, .presentationContextNotProvided:
                        Log.breadcrumb(category: "auth", level: .error, message: "ASWebAuthenticationSessionError: \(nested.localizedDescription)")
                        Log.capture(error: nested)
                    default:
                        return
                    }
                } else {
                    Log.breadcrumb(category: "auth", level: .error, message: "Error: \(nested.localizedDescription)")
                    Log.capture(error: error)
                }
            }
        }
        authenticationState = .ready
    }

    private func handle(_ response: AuthorizationClient.Response) {
        appSession.currentSession = Session(
            guid: response.guid,
            accessToken: response.accessToken,
            userIdentifier: response.userIdentifier
        )
        // Post that we logged in to the rest of the app
        // Note when we pass appSession.currentSession it seems to pass a nil object to NotificatioNcenter, but when we save the value and we pass the basic struct it works perfectly
        NotificationCenter.default.post(name: .userLoggedIn, object: appSession.currentSession)
    }
}

extension Authenticator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
