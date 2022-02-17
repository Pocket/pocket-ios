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
    private let sessionController: SessionController
    private let events: PocketEvents

    init(
        authorizationClient: AuthorizationClient,
        sessionController: SessionController,
        events: PocketEvents
    ) {
        self.authorizationClient = authorizationClient
        self.sessionController = sessionController
        self.events = events
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
                let session = Session(
                    guid: guid,
                    accessToken: response.accessToken,
                    userIdentifier: response.userIdentifier
                )
                sessionController.updateSession(session)
                events.send(.signedIn)
            } else {
                presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
            }
        } catch {
            presentedAlert = PocketAlert(LoggedOutError.error) { [weak self] in self?.presentedAlert = nil }
        }
    }
}
