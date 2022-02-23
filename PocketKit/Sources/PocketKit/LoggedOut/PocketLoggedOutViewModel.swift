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
        Task { [weak self] in await self?._login() }
    }

    private func _login() async {
        guard let contextProvider = contextProvider else {
            presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
            return
        }

        do {
            let guid = try await authorizationClient.requestGUID()

            let (_, response) = await authorizationClient.logIn(from: contextProvider)
            if let response = response {
                appSession.currentSession = Session(
                    guid: guid,
                    accessToken: response.accessToken,
                    userIdentifier: response.userIdentifier
                )
            } else {
                presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
            }
        } catch {
            presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
        }
    }
}
