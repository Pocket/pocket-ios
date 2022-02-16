@testable import PocketKit
import Combine
import AuthenticationServices


struct MockLoggedOutViewModel: LoggedOutViewModel {
    var _events = PassthroughSubject<LoggedOutViewModelEvent, Never>()
    var events: AnyPublisher<LoggedOutViewModelEvent, Never> {
        _events.eraseToAnyPublisher()
    }

    var contextProvider: ASWebAuthenticationPresentationContextProviding? = nil

    func logIn() {
        
    }
}
