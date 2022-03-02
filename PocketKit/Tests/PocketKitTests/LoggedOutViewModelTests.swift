import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices
import Sync


class LoggedOutViewModelTests: XCTestCase {
    private var authorizationClient: AuthorizationClient!
    private var appSession: AppSession!
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        authorizationClient = AuthorizationClient(
            consumerKey: "test-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )
        appSession = AppSession(keychain: MockKeychain())
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        authorizationClient: AuthorizationClient? = nil,
        appSession: AppSession? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil
    ) -> LoggedOutViewModel {
        let viewModel = LoggedOutViewModel(
            authorizationClient: authorizationClient ?? self.authorizationClient,
            appSession: appSession ?? self.appSession,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor
        )
        viewModel.contextProvider = self
        return viewModel
    }
}

extension LoggedOutViewModelTests {
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

extension LoggedOutViewModelTests {
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

extension LoggedOutViewModelTests {
    func test_logIn_whenOffline_setsPresentOfflineViewToTrue() {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "update presentOfflineView")
        viewModel.$presentOfflineView.dropFirst().sink { present in
            XCTAssertTrue(present)
            offlineExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [offlineExpectation], timeout: 1)
    }

    func test_logIn_whenOffline_thenReconnects_setsPresentOfflineViewToFalse() {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "set presentOfflineView to true")
        let onlineExpectation = expectation(description: "set presentOfflineView to false")
        var count = 0
        viewModel.$presentOfflineView.dropFirst().sink { present in
            count += 1
            if count == 1 {
                XCTAssertTrue(present)
                offlineExpectation.fulfill()
            } else if count == 2 {
                XCTAssertFalse(present)
                onlineExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        viewModel.logIn()
        networkPathMonitor.update(status: .satisfied)
        wait(for: [offlineExpectation, onlineExpectation], timeout: 1, enforceOrder: true)
    }

    func test_signUp_whenOffline_setsPresentOfflineViewToTrue() {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "update presentOfflineView")
        viewModel.$presentOfflineView.dropFirst().sink { present in
            XCTAssertTrue(present)
            offlineExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [offlineExpectation], timeout: 1)
    }

    func test_signUp_whenOffline_thenReconnects_setsPresentOfflineViewToFalse() {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "set presentOfflineView to true")
        let onlineExpectation = expectation(description: "set presentOfflineView to false")
        var count = 0
        viewModel.$presentOfflineView.dropFirst().sink { present in
            count += 1
            if count == 1 {
                XCTAssertTrue(present)
                offlineExpectation.fulfill()
            } else if count == 2 {
                XCTAssertFalse(present)
                onlineExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        viewModel.signUp()
        networkPathMonitor.update(status: .satisfied)
        wait(for: [offlineExpectation, onlineExpectation], timeout: 1, enforceOrder: true)
    }
}

extension LoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
