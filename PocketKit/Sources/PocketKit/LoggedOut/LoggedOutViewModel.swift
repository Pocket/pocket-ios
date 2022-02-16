import Combine
import AuthenticationServices


enum LoggedOutViewModelError: Error {
    case error
}

enum LoggedOutViewModelEvent {
    case error(LoggedOutViewModelError)
    case login(Authentication)
}

struct Authentication {
    let guid: String
    let accessToken: String
    let userIdentifier: String
}

protocol LoggedOutViewModel {
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> { get }
    var contextProvider: ASWebAuthenticationPresentationContextProviding? { get set }

    func logIn()
}
