import Foundation
import Combine
import AuthenticationServices
import Sync
import SwiftUI


enum LoggedOutError: Error {
    case error
}

class PocketLoggedOutViewModel: ObservableObject {
    weak var contextProvider: ASWebAuthenticationPresentationContextProviding?

    private var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    @Published
    var presentedAlert: PocketAlert? = nil

    @Published
    var presentOfflineView: Bool = false

    private let authorizationClient: AuthorizationClient
    private let appSession: AppSession
    private let networkPathMonitor: NetworkPathMonitor

    init(
        authorizationClient: AuthorizationClient,
        appSession: AppSession,
        networkPathMonitor: NetworkPathMonitor
    ) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
        self.networkPathMonitor = networkPathMonitor

        networkPathMonitor.start(queue: DispatchQueue.global())
    }

    func logIn() {
        guard !isOffline else {
            presentOfflineView = true
            return
        }

        Task { [weak self] in
            await self?.authenticate(authorizationClient.logIn)
        }
    }

    func signUp() {
        guard !isOffline else {
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
    }
}
