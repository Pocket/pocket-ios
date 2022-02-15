import Foundation
import Combine


class PocketLoggedOutViewModel: LoggedOutViewModel {
    private var _session = PassthroughSubject<AuthenticationSession, Never>()
    var session: AnyPublisher<AuthenticationSession, Never> {
        _session.eraseToAnyPublisher()
    }

    private var _events = PassthroughSubject<LoggedOutViewModelEvent, Never>()
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    private let consumerKey: String
    private let sessionType: AuthenticationSession.Type

    init(consumerKey: String, sessionType: AuthenticationSession.Type) {
        self.consumerKey = consumerKey
        self.sessionType = sessionType
    }

    func logIn() {
        guard var components = URLComponents(string: "https://getpocket.com/login") else {
            return
        }

        let redirect = "pocket"

        components.queryItems = [
            URLQueryItem(name: "consumer_key", value: consumerKey),
            URLQueryItem(name: "redirect_uri", value: "\(redirect)://fxa"),
            URLQueryItem(name: "utm_source", value: "ios")
        ]

        guard let url = components.url else {
            return
        }

        var authSession = sessionType.init(url: url, callbackURLScheme: redirect) { [weak self] url, error in
            if let error = error {
                self?._events.send(.error(error))
            } else if let url = url {
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value else {
                    // TODO: What do?
                    return
                }

                self?._events.send(.login(token))
            } else {
                // TODO: What do?
            }
        }
        authSession.prefersEphemeralWebBrowserSession = true
        _session.send(authSession)
    }
}
