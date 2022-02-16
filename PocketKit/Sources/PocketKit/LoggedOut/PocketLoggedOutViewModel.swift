import Foundation
import Combine
import AuthenticationServices


class PocketLoggedOutViewModel: LoggedOutViewModel {
    private var _events = PassthroughSubject<LoggedOutViewModelEvent, Never>()
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    weak var contextProvider: ASWebAuthenticationPresentationContextProviding?

    private let authorizationClient: AuthorizationClient

    init(authorizationClient: AuthorizationClient) {
        self.authorizationClient = authorizationClient
    }

    func logIn() {
        Task { [weak self] in await self?._login() }
    }

    private func _login() async {
        guard let contextProvider = contextProvider else {
            _events.send(.error(.error))
            return
        }


        do {
            let guid = try await authorizationClient.requestGUID()

            let (_, response) = await authorizationClient.logIn(from: contextProvider)
            if let response = response {
                let auth = Authentication(guid: guid, accessToken: response.accessToken, userIdentifier: response.userIdentifier)
                _events.send(.login(auth))
            } else {
                _events.send(.error(.error))
            }
        } catch {
            _events.send(.error(.error))
        }
    }
}
