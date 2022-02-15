import Combine


enum LoggedOutViewModelEvent {
    case error(Error)
    case login(String)
}

protocol LoggedOutViewModel {
    var session: AnyPublisher<AuthenticationSession, Never> { get }
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> { get }

    func logIn()
}
