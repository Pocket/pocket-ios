// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AuthenticationServices
import Combine
import SharedPocketKit

/// Core service that determines the access level to the app. Full access is granted upon authentication. Anonymous access provides limited access.
/// The property `accessLevel` reflects what type of access the current user is granted.
@MainActor
final class PocketAccessService: NSObject, ObservableObject {
    /// An enum containing all possible access states
    enum AccessLevel {
        case onboarding // onboarding screen only
        case anonymous // limited access
        case authenticated // full access
    }

    private let authorizationClient: AuthorizationClient
    private let appSession: AppSession

    private var subscriptions = Set<AnyCancellable>()

    /// (re)publish current session changes in the form of `AccessLevel`.
    /// Used to track access level state changes.
    @Published private(set) var accessLevel: AccessLevel
    /// Publish any authentication related error, for the client to manage.
    @Published private(set) var authenticationError: Error?

    init(authorizationClient: AuthorizationClient, appSession: AppSession) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        if let session = appSession.currentSession {
            self.accessLevel = session.isAnonymous ? .anonymous : .authenticated
        } else {
            self.accessLevel = .onboarding
        }
        super.init()
        appSession
            .$currentSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                if let session {
                    self?.accessLevel = session.isAnonymous ? .anonymous : .authenticated
                } else {
                    self?.accessLevel = .onboarding
                }
            }
            .store(in: &subscriptions)
    }

    /// Request authenticated access for the current user
    func requestAuthentication() {
        Task { [weak self] in
            guard let self else {
                return
            }
            await self.parseResponse(authenticator: self.authorizationClient.authenticate)
        }
    }

    /// Request anonymous access for the current user
    func requestAnonymousAccess() {
        appSession.setAnonymousSession()
        accessLevel = .anonymous
    }

    /// Parse response from `AuthorizationClient`, provided by the passed authentication closuse
    /// - Parameter authentication: the authentication closure
    private func parseResponse(authenticator: (ASWebAuthenticationPresentationContextProviding?) async throws -> AuthorizationClient.Response) async {
        do {
            let response = try await authenticator(self)
            handle(response)
        } catch {
            if let authError = error as? AuthorizationClient.Error,
                case let .other(nested) = authError {
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
            authenticationError = error
        }
    }

    private func handle(_ response: AuthorizationClient.Response) {
        let session = Session(
            guid: response.guid,
            accessToken: response.accessToken,
            userIdentifier: response.userIdentifier
        )
        appSession.setCurrentSession(session)
    }
}

extension PocketAccessService: ASWebAuthenticationPresentationContextProviding {
    // TODO: SIGNEDOUT - verify that using a generic presentation anchor instead of the current window
    // does not introduce any issues
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
