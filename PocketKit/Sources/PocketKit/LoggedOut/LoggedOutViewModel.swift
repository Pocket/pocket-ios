import Foundation
import Combine
import AuthenticationServices
import Sync
import SwiftUI
import Network
import Analytics


enum LoggedOutError: Error {
    case error
}

enum LoggedOutAction {
    case logIn
    case signUp
}

class LoggedOutViewModel: ObservableObject {
    weak var contextProvider: ASWebAuthenticationPresentationContextProviding?

    @Published
    var presentedAlert: PocketAlert? = nil

    @Published
    var isPresentingOfflineView: Bool = false
    private(set) var automaticallyDismissed = false
    private(set) var lastAction: LoggedOutAction? = nil

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

    private func authenticate(_ authentication: (ASWebAuthenticationPresentationContextProviding) async -> (AuthorizationClient.Request?, AuthorizationClient.Response?)) async {
        guard let contextProvider = contextProvider else {
            presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
            lastAction = nil
            return
        }

        let (_, response) = await authentication(contextProvider)
        if let response = response {
            appSession.currentSession = Session(
                guid: response.guid,
                accessToken: response.accessToken,
                userIdentifier: response.userIdentifier
            )
        } else {
            presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
        }

        lastAction = nil
    }
}
