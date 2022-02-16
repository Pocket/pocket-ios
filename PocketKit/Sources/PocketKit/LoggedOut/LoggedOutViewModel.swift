import Combine
import AuthenticationServices


enum LoggedOutViewModelError: Error {
    case error
}

enum LoggedOutViewModelEvent {
    case error(LoggedOutViewModelError)
    case login(String)
}

protocol LoggedOutViewModel {
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> { get }
    var contextProvider: ASWebAuthenticationPresentationContextProviding? { get set }

    func logIn()
}
