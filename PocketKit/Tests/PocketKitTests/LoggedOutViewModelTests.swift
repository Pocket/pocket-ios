import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices
import Sync
import Analytics
import SharedPocketKit


class LoggedOutViewModelTests: XCTestCase {
    private var authorizationClient: AuthorizationClient!
    private var appSession: AppSession!
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var tracker: MockTracker!
    private var mockAuthenticationSession: MockAuthenticationSession!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        authorizationClient = AuthorizationClient(consumerKey: "the-consumer-key") { (_, _, completion) in
            self.mockAuthenticationSession.completionHandler = completion
            return self.mockAuthenticationSession
        }
        appSession = AppSession(keychain: MockKeychain())
        networkPathMonitor = MockNetworkPathMonitor()
        tracker = MockTracker()
        mockAuthenticationSession = MockAuthenticationSession()
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        authorizationClient: AuthorizationClient? = nil,
        appSession: AppSession? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil,
        tracker: Tracker? = nil
    ) -> LoggedOutViewModel {
        let viewModel = LoggedOutViewModel(
            authorizationClient: authorizationClient ?? self.authorizationClient,
            appSession: appSession ?? self.appSession,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            tracker: tracker ?? self.tracker
        )
        viewModel.contextProvider = self
        return viewModel
    }
}

extension LoggedOutViewModelTests {
    func test_logIn_onFxAError_setsPresentedAlert() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        let viewModel = subject()

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        await viewModel.logIn()

        wait(for: [alertExpectation], timeout: 1)
    }

    func test_logIn_onFxASuccess_updatesSession() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!
        let viewModel = subject()

        let sessionExpectation = expectation(description: "published error event")
        appSession.$currentSession.dropFirst().sink { session in
            XCTAssertEqual(session?.guid, "test-guid")
            XCTAssertEqual(session?.accessToken, "test-access-token")
            XCTAssertEqual(session?.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        await viewModel.logIn()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension LoggedOutViewModelTests {
    func test_signUp_onFxAError_setsPresentedAlert() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        let viewModel = subject()

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        await viewModel.signUp()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_signUp_onFxASuccess_updatesSession() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!
        let viewModel = subject()

        let sessionExpectation = expectation(description: "published error event")
        appSession.$currentSession.dropFirst().sink { session in
            XCTAssertEqual(session?.guid, "test-guid")
            XCTAssertEqual(session?.accessToken, "test-access-token")
            XCTAssertEqual(session?.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        await viewModel.signUp()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension LoggedOutViewModelTests {
    func test_logIn_whenOffline_setsPresentOfflineViewToTrue() async {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "update presentOfflineView")
        viewModel.$isPresentingOfflineView.dropFirst().sink { present in
            XCTAssertTrue(present)
            offlineExpectation.fulfill()
        }.store(in: &subscriptions)

        await viewModel.logIn()
        wait(for: [offlineExpectation], timeout: 1)
    }

    func test_logIn_whenOffline_thenReconnects_setsPresentOfflineViewToFalse() async {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "set presentOfflineView to true")
        let onlineExpectation = expectation(description: "set presentOfflineView to false")
        var count = 0
        viewModel.$isPresentingOfflineView.dropFirst().sink { present in
            count += 1
            if count == 1 {
                XCTAssertTrue(present)
                offlineExpectation.fulfill()
            } else if count == 2 {
                XCTAssertFalse(present)
                onlineExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        await viewModel.logIn()
        networkPathMonitor.update(status: .satisfied)
        wait(for: [offlineExpectation, onlineExpectation], timeout: 1, enforceOrder: true)
    }

    func test_signUp_whenOffline_setsPresentOfflineViewToTrue() async {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "update presentOfflineView")
        viewModel.$isPresentingOfflineView.dropFirst().sink { present in
            XCTAssertTrue(present)
            offlineExpectation.fulfill()
        }.store(in: &subscriptions)

        await viewModel.signUp()
        wait(for: [offlineExpectation], timeout: 1)
    }

    func test_signUp_whenOffline_thenReconnects_setsPresentOfflineViewToFalse() async {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "set presentOfflineView to true")
        let onlineExpectation = expectation(description: "set presentOfflineView to false")
        var count = 0
        viewModel.$isPresentingOfflineView.dropFirst().sink { present in
            count += 1
            if count == 1 {
                XCTAssertTrue(present)
                offlineExpectation.fulfill()
            } else if count == 2 {
                XCTAssertFalse(present)
                onlineExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        await viewModel.signUp()
        networkPathMonitor.update(status: .satisfied)
        wait(for: [offlineExpectation, onlineExpectation], timeout: 1, enforceOrder: true)
    }
}

extension LoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
