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
    private var userManagementService: MockUserManagementService!

    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        authorizationClient = AuthorizationClient(consumerKey: "the-consumer-key", adjustSignupEventToken: "token") { (_, _, completion) in
            self.mockAuthenticationSession.completionHandler = completion
            return self.mockAuthenticationSession
        }
        appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
        networkPathMonitor = MockNetworkPathMonitor()
        tracker = MockTracker()
        mockAuthenticationSession = MockAuthenticationSession()
        userManagementService = MockUserManagementService()

        subscriptions = []

        mockAuthenticationSession.stubStart {
            self.mockAuthenticationSession.completionHandler?(
                self.mockAuthenticationSession.url,
                self.mockAuthenticationSession.error
            )
            return true
        }
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
            tracker: tracker ?? self.tracker,
            userManagementService: userManagementService ?? self.userManagementService
        )
        viewModel.contextProvider = self
        return viewModel
    }
}

extension LoggedOutViewModelTests {
    func test_logIn_withExistingSession_doesNotAttemptAuthentication() async {
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )

        let startExpectation = expectation(description: "expected start to not be called")
        startExpectation.isInverted = true
        mockAuthenticationSession.stubStart {
            startExpectation.fulfill()
            return true
        }

        let viewModel = subject()
        await viewModel.logIn()

        wait(for: [startExpectation], timeout: 1)
    }

    @MainActor
    func test_logIn_onFxAError_setsPresentedAlert() {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        let viewModel = subject()

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()

        wait(for: [alertExpectation], timeout: 1)
    }

    @MainActor
    func test_logIn_onFxASuccess_updatesSession() {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!
        let viewModel = subject()

        let sessionExpectation = expectation(description: "published error event")

        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { notification in
            guard let session = notification.object as? SharedPocketKit.Session  else {
                XCTFail("Session did not exist in notification center")
                return
            }
            XCTAssertEqual(session.guid, "test-guid")
            XCTAssertEqual(session.accessToken, "test-access-token")
            XCTAssertEqual(session.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension LoggedOutViewModelTests {
    func test_signUp_withExistingSession_doesNotAttemptAuthentication() async {
        appSession.currentSession = Session(
            guid: "mock-guid",
            accessToken: "mock-access-token",
            userIdentifier: "mock-user-identifier"
        )

        let startExpectation = expectation(description: "expected start to not be called")
        startExpectation.isInverted = true
        mockAuthenticationSession.stubStart {
            startExpectation.fulfill()
            return true
        }

        let viewModel = subject()
        await viewModel.signUp()

        wait(for: [startExpectation], timeout: 1)
    }

    @MainActor
    func test_signUp_onFxAError_setsPresentedAlert() {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        let viewModel = subject()

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [alertExpectation], timeout: 1)
    }

    @MainActor
    func test_signUp_onFxASuccess_updatesSession() {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!
        let viewModel = subject()

        let sessionExpectation = expectation(description: "published error event")

        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { notification in
            guard let session = notification.object as? SharedPocketKit.Session  else {
                XCTFail("Session did not exist in notification center")
                return
            }
            XCTAssertEqual(session.guid, "test-guid")
            XCTAssertEqual(session.accessToken, "test-access-token")
            XCTAssertEqual(session.userIdentifier, "test-id")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
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
