import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices


class PocketLoggedOutViewModelTests: XCTestCase {
    private var authorizationClient: AuthorizationClient!
    private var appSession: AppSession!
    private var subscriptions: Set<AnyCancellable>!

    @Published
    var foo: String = ""

    override func setUp() {
        authorizationClient = AuthorizationClient(
            consumerKey: "test-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )
        appSession = AppSession(keychain: MockKeychain())
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        authorizationClient: AuthorizationClient? = nil,
        appSession: AppSession? = nil
    ) -> PocketLoggedOutViewModel {
        let viewModel = PocketLoggedOutViewModel(
            authorizationClient: authorizationClient ?? self.authorizationClient,
            appSession: appSession ?? self.appSession
        )
        viewModel.contextProvider = self
        return viewModel
    }
}

extension PocketLoggedOutViewModelTests {
    func test_logIn_onFxAError_setsPresentedAlert() {
        let failingClient = AuthorizationClient(
            consumerKey: "test-consumer-key",
            authenticationSession: MockErrorAuthenticationSession.self
        )
        let viewModel = subject(authorizationClient: failingClient)

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_logIn_onFxASuccess_updatesSession() {
        let viewModel = subject()

        let sessionExpectation = expectation(description: "published error event")
        appSession.$currentSession.dropFirst().sink { session in
            XCTAssertEqual(session?.guid, "test-guid")
            XCTAssertEqual(session?.accessToken, "test-access-token")
            XCTAssertEqual(session?.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension PocketLoggedOutViewModelTests {
    func test_signUp_onFxAError_setsPresentedAlert() {
        let failingClient = AuthorizationClient(
            consumerKey: "test-consumer-key",
            authenticationSession: MockErrorAuthenticationSession.self
        )
        let viewModel = subject(authorizationClient: failingClient)

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_signUp_onFxASuccess_updatesSession() {
        let viewModel = subject()

        let sessionExpectation = expectation(description: "published error event")
        appSession.$currentSession.dropFirst().sink { session in
            XCTAssertEqual(session?.guid, "test-guid")
            XCTAssertEqual(session?.accessToken, "test-access-token")
            XCTAssertEqual(session?.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension PocketLoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
