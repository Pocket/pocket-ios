import Foundation
import Combine
import AuthenticationServices
import Sync
import SwiftUI
import Network


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
    var presentOfflineView: Bool = false
    private(set) var automaticallyDismissed = false
    private(set) var lastAction: LoggedOutAction? = nil

    private let authorizationClient: AuthorizationClient
    private let appSession: AppSession

    private let networkPathMonitor: NetworkPathMonitor
    private(set) var currentNetworkStatus: NWPath.Status
    private var isOffline: Bool {
        currentNetworkStatus == .unsatisfied
    }

    init(
        authorizationClient: AuthorizationClient,
        appSession: AppSession,
        networkPathMonitor: NetworkPathMonitor
    ) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        self.networkPathMonitor = networkPathMonitor

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

        if currentNetworkStatus == .unsatisfied, status == .satisfied, presentOfflineView == true {
            automaticallyDismissed = true
            presentOfflineView = false
        }
        currentNetworkStatus = status
    }

    @MainActor
    func logIn() {
        lastAction = .logIn

        guard !isOffline else {
            automaticallyDismissed = false
            presentOfflineView = true
            return
        }

        Task { [weak self] in
            await self?.authenticate(authorizationClient.logIn)
        }
    }

    @MainActor
    func signUp() {
        lastAction = .signUp

        guard !isOffline else {
            automaticallyDismissed = false
            presentOfflineView = true
            return
        }

        Task { [weak self] in
            await self?.authenticate(authorizationClient.signUp)
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
