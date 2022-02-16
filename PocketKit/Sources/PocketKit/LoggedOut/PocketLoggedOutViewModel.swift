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

        let (_, response) = await self.authorizationClient.logIn(from: contextProvider)
        if let response = response {
            _events.send(.login(response.accessToken))
        } else {
            _events.send(.error(.error))
        }
    }
}
