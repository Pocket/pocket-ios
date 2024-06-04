// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Combine
import AuthenticationServices
import Sync
import SwiftUI
import Network
import Analytics
import SharedPocketKit

enum LoggedOutAction {
    case authenticate
}

@MainActor
class LoggedOutViewModel: ObservableObject {
    var contextProvider: ASWebAuthenticationPresentationContextProviding?

    @Published var presentedAlert: PocketAlert?

    @Published var isPresentingOfflineView: Bool = false

    @Published var isPresentingExitSurveyBanner: Bool = false

    @Published var isPresentingExitSurvey: Bool = false

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
    private let userManagementService: UserManagementServiceProtocol
    private var cancellables: Set<AnyCancellable> = []

    convenience init() {
        self.init(authorizationClient: Services.shared.authClient, appSession: Services.shared.appSession, networkPathMonitor: NWPathMonitor(), tracker: Services.shared.tracker, userManagementService: Services.shared.userManagementService)
    }

    init(
        authorizationClient: AuthorizationClient,
        appSession: AppSession,
        networkPathMonitor: NetworkPathMonitor,
        tracker: Tracker,
        userManagementService: UserManagementServiceProtocol
    ) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        self.networkPathMonitor = networkPathMonitor
        self.tracker = tracker
        self.userManagementService = userManagementService

        networkPathMonitor.start(queue: DispatchQueue.global())
        currentNetworkStatus = networkPathMonitor.currentNetworkPath.status
        networkPathMonitor.updateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateStatus(path.status)
            }
        }

        // Register for the user management service to show the deletion banner if the user logs out.
        self.userManagementService
            .accountDeletedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accountDeleted in self?.isPresentingExitSurveyBanner = accountDeleted }
            .store(in: &cancellables)
        self.isPresentingExitSurveyBanner = self.userManagementService.accountDeleted

        // Set up impression analytics in our view model when the banner shows.
        $isPresentingExitSurveyBanner
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] value in
                guard let self else {
                    Log.capture(message: "Not tracking deletion banner impression, due to a weak self")
                    return
                }

                if value {
                    self.trackExitSurveyBannerImpression()
                }
            }
            .store(in: &cancellables)
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

    func exitSurveyButtonClicked() {
        self.isPresentingExitSurvey.toggle()
        tracker.track(event: Events.Login.deleteAccountExitSurveyBannerTap())
    }

    func exitSurveyAppeared() {
        tracker.track(event: Events.Login.deleteAccountExitSurveyImpression())
    }

    func trackExitSurveyBannerImpression() {
        tracker.track(event: Events.Login.deleteAccountExitSurveyBannerImpression())
    }

    func authenticate() {
        guard appSession.currentSession == nil else {
            return
        }

        lastAction = .authenticate
        tracker.track(event: Events.Login.continueButtonTapped())

        guard !isOffline else {
            automaticallyDismissed = false
            isPresentingOfflineView = true
            return
        }

        Task { [weak self] in
            guard let self else {
                return
            }
            await self.authenticate(self.authorizationClient.authenticate)
        }
    }

    func offlineViewDidDisappear() {
        if automaticallyDismissed, case .authenticate = lastAction {
            authenticate()
        }
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

    private func present(_ error: Error) {
        presentedAlert = PocketAlert(error) { [weak self] in
            self?.presentedAlert = nil
        }
    }

    private func authenticate(_ authentication: (ASWebAuthenticationPresentationContextProviding?) async throws -> AuthorizationClient.Response) async {
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
                present(error)
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

        lastAction = nil
    }
}
