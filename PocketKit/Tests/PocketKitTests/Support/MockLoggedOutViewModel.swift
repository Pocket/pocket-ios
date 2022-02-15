@testable import PocketKit
import Combine


struct MockLoggedOutViewModel: LoggedOutViewModel {
    var _session = PassthroughSubject<AuthenticationSession, Never>()
    var session: AnyPublisher<AuthenticationSession, Never> {
        _session.eraseToAnyPublisher()
    }

    var _events = PassthroughSubject<LoggedOutViewModelEvent, Never>()
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    func logIn() {
        
    }
}
