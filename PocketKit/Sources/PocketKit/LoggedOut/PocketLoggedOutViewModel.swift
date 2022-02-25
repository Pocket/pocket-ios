import Foundation
import Combine
import AuthenticationServices


enum LoggedOutError: Error {
    case error
}
class PocketLoggedOutViewModel {
    weak var contextProvider: ASWebAuthenticationPresentationContextProviding?

    @Published
    var presentedAlert: PocketAlert? = nil

    private let authorizationClient: AuthorizationClient
    private let appSession: AppSession

    init(
        authorizationClient: AuthorizationClient,
        appSession: AppSession
    ) {
        self.authorizationClient = authorizationClient
        self.appSession = appSession
    }

    func logIn() {
        Task { [weak self] in
            await self?.authenticate(authorizationClient.logIn)
        }
    }

    func signUp() {
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
