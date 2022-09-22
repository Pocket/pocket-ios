import Foundation
import Combine
import AuthenticationServices
import Sync
import SwiftUI
import Network
import Analytics
import SharedPocketKit

enum LoggedOutAction {
    case logIn
    case signUp
}

class LoggedOutViewModel: ObservableObject {
    weak var contextProvider: ASWebAuthenticationPresentationContextProviding?

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var isPresentingOfflineView: Bool = false
    private(set) var automaticallyDismissed = false
    private(set) var lastAction: LoggedOutAction?

    private(set) var currentNetworkStatus: NWPath.Status
    private var isOffline: Bool {
        currentNetworkStatus == .unsatisfied
    }

    private let authorizationClient: AuthorizationClient
    private let appSession: AppSession
    private let networkPathMonitor: NetworkPathMonitor
    private let tracker: Tracker

    init(
        authorizationClient: AuthorizationClient,
        appSession: AppSession,
        networkPathMonitor: NetworkPathMonitor,
        tracker: Tracker
    ) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        self.networkPathMonitor = networkPathMonitor
        self.tracker = tracker

        networkPathMonitor.start(queue: DispatchQueue.global())
        currentNetworkStatus = networkPathMonitor.currentNetworkPath.status
        networkPathMonitor.updateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateStatus(path.status)
            }
        }
    }

    private func updateStatus(_ status: NWPath.Status) {
        guard status != currentNetworkStatus else {
            return
        }

        if currentNetworkStatus == .unsatisfied, status == .satisfied, isPresentingOfflineView == true {
            automaticallyDismissed = true
            isPresentingOfflineView = false
        }
        currentNetworkStatus = status
    }

    @MainActor
    func logIn() {
        guard appSession.currentSession == nil else {
            return
        }

        lastAction = .logIn

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            [UIContext.button(identifier: .logIn)]
        )

        guard !isOffline else {
            automaticallyDismissed = false
            isPresentingOfflineView = true
            return
        }

        Task { [weak self] in
            await self?.authenticate(authorizationClient.logIn)
        }
    }

    @MainActor
    func signUp() {
        guard appSession.currentSession == nil else {
            return
        }

        lastAction = .signUp

        tracker.track(
            event: SnowplowEngagement(type: .general, value: nil),
            [UIContext.button(identifier: .signUp)]
        )

        guard !isOffline else {
            automaticallyDismissed = false
            isPresentingOfflineView = true
            return
        }

        Task { [weak self] in
            await self?.authenticate(authorizationClient.signUp)
        }
    }

    func offlineViewDidDisappear() {
        if automaticallyDismissed {
            switch lastAction {
            case .logIn:
                Task { await logIn() }
            case .signUp:
                Task { await signUp() }
            default:
                return
            }
        }
    }

    @MainActor
    private func handle(_ response: AuthorizationClient.Response) {
        appSession.currentSession = Session(
            guid: response.guid,
            accessToken: response.accessToken,
            userIdentifier: response.userIdentifier
        )
        // Post that we logged in to the rest of the app
        NotificationCenter.default.post(name: .userLoggedIn, object: appSession.currentSession)
    }

    @MainActor
    private func present(_ error: Error) {
        presentedAlert = PocketAlert(error) { [weak self] in
            self?.presentedAlert = nil
        }
    }

    private func authenticate(_ authentication: (ASWebAuthenticationPresentationContextProviding?) async throws -> AuthorizationClient.Response) async {
        do {
            let response = try await authentication(contextProvider)
            await handle(response)
        } catch {
            // AuthorizationClient should only ever throw an AuthorizationClient.error
            guard let error = error as? AuthorizationClient.Error else {
                Crashlogger.capture(error: error)
                return
            }

            switch error {
            case .invalidRedirect, .invalidComponents:
                // If component generation failed, we should alert the user (to hopefully reach out),
                // as well as capture the error
                await present(error)
                Crashlogger.capture(error: error)
            case .alreadyAuthenticating:
                Crashlogger.capture(error: error)
            case .other(let nested):
                // All other errors will be throws by the AuthenticationSession,
                // which in production will be ASWebAuthenticationSessionError.
                // However, capture any other errors (if one exists)
                if let nested = nested as? ASWebAuthenticationSessionError {
                    // We can ignore the "error" if a user has cancelled authentication,
                    // but the other errors should never occur, so they should be captured.
                    switch nested.code {
                    case .presentationContextInvalid, .presentationContextNotProvided:
                        Crashlogger.capture(error: nested)
                    default:
                        return
                    }
                } else {
                    Crashlogger.capture(error: error)
                }
            }
        }

        lastAction = nil
    }
}
