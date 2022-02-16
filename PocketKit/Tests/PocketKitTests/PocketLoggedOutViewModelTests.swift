import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices


class PocketLoggedOutViewModelTests: XCTestCase {
    private var viewModel: PocketLoggedOutViewModel!
    private var subscriptions: Set<AnyCancellable>!

    @Published
    var foo: String = ""

    override func setUp() {
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }

    func test_logIn_onError_sendsErrorEvent() {
        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: MockURLSession(),
            authenticationSession: MockErrorAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(authorizationClient: client)
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .error = event else {
                XCTFail("Expected error event, but got \(event)")
                return
            }
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [eventExpectation], timeout: 1)
    }

    func test_logIn_onSuccess_sendsLoginEvent() {
        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: MockURLSession(),
            authenticationSession: MockAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(authorizationClient: client)
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .login(let token) = event else {
                XCTFail("Expected login event, but got \(event)")
                return
            }
            XCTAssertEqual(token, "test-access-token")
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [eventExpectation], timeout: 1)
    }
}

extension PocketLoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
