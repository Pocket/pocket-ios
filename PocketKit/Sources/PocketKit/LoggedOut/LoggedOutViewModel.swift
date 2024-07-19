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
    case continueSignedOut
}

@MainActor
class LoggedOutViewModel: ObservableObject {
    var contextProvider: ASWebAuthenticationPresentationContextProviding?

    @Published var presentedAlert: PocketAlert?

    @Published var isPresentingOfflineView: Bool = false

    @Published var isPresentingExitSurveyBanner: Bool = false

    @Published var isPresentingExitSurvey: Bool = false

    @Published var showNewOnboarding: Bool = false

    private(set) var automaticallyDismissed = false
    private(set) var lastAction: LoggedOutAction?
    private let featureFlags: FeatureFlagServiceProtocol
    private let refreshCoordinator: RefreshCoordinator

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

    private let authenticator: Authenticator

    convenience init() {
        self.init(authorizationClient: Services.shared.authClient, appSession: Services.shared.appSession, networkPathMonitor: NWPathMonitor(), tracker: Services.shared.tracker, userManagementService: Services.shared.userManagementService, featureFlags: Services.shared.featureFlagService, refreshCoordinator: Services.shared.featureFlagsRefreshCoordinator)
    }

    init(
        authorizationClient: AuthorizationClient,
        appSession: AppSession,
        networkPathMonitor: NetworkPathMonitor,
        tracker: Tracker,
        userManagementService: UserManagementServiceProtocol,
        featureFlags: FeatureFlagServiceProtocol,
        refreshCoordinator: RefreshCoordinator
    ) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        self.networkPathMonitor = networkPathMonitor
        self.tracker = tracker
        self.userManagementService = userManagementService
        self.featureFlags = featureFlags
        self.refreshCoordinator = refreshCoordinator
        // TODO: - SIGNEDOUT - authenticator could be directly provided by Services
        self.authenticator = Authenticator(authorizationClient: authorizationClient, appSession: appSession)

        networkPathMonitor.start(queue: DispatchQueue.main)
        currentNetworkStatus = networkPathMonitor.currentNetworkPath.status
        networkPathMonitor.updateHandler = { [weak self] path in
            self?.updateStatus(path.status)
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
        // TODO: SIGNEDOUT - Once we release, the feature flag service and fetch shall be removed from here
        refreshCoordinator.refresh(isForced: false) { [weak self] in
            guard let self else {
                return
            }
            showNewOnboarding = true // featureFlags.isAssigned(flag: .newOnboarding)
        }

        authenticator
            .$authenticationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .ready:
                    lastAction = nil
                case .error(let error):
                    present(error)
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

    func presentExitSurvey() {
        self.isPresentingExitSurvey.toggle()
        tracker.track(event: Events.Login.deleteAccountExitSurveyBannerTap())
    }

    func exitSurveyAppeared() {
        tracker.track(event: Events.Login.deleteAccountExitSurveyImpression())
    }

    func trackExitSurveyBannerImpression() {
        tracker.track(event: Events.Login.deleteAccountExitSurveyBannerImpression())
    }

    /// Called from the `Sign up or sign in` button
    func signUpOrSignIn() {
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
        authenticator.authenticate()
    }

    /// Called from the `Skip sign in` button
    func skipSignIn() {
        lastAction = .continueSignedOut
        guard !isOffline else {
            automaticallyDismissed = false
            isPresentingOfflineView = true
            return
        }

        authenticator.anonymousAccess()
    }

    func offlineViewDidDisappear() {
        if automaticallyDismissed {
            switch lastAction {
            case .authenticate:
                signUpOrSignIn()
            case .continueSignedOut:
                skipSignIn()
            case nil:
                break
            }
        }
    }

    private func present(_ error: Error) {
        presentedAlert = PocketAlert(error) { [weak self] in
            self?.presentedAlert = nil
        }
    }
}
