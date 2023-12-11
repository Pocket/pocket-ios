// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
        super.setUp()
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
        super.tearDown()
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

        await fulfillment(of: [startExpectation], timeout: 10)
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

        wait(for: [alertExpectation], timeout: 10)
    }
// TODO: Fix this in the ui test pr to not use the default notification center
//    @MainActor
//    func test_logIn_onFxASuccess_updatesSession() {
//        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!
//        let sessionExpectation = expectation(description: "published error event")
//
//        NotificationCenter.default.publisher(
//            for: .userLoggedIn
//        ).sink { notification in
//            guard let session = notification.object as? SharedPocketKit.Session  else {
//                XCTFail("Session did not exist in notification center")
//                return
//            }
//            XCTAssertEqual(session.guid, "test-guid")
//            XCTAssertEqual(session.accessToken, "test-access-token")
//            XCTAssertEqual(session.userIdentifier, "test-id")
//            sessionExpectation.fulfill()
//        }.store(in: &subscriptions)
//
//        let viewModel = subject()
//        viewModel.logIn()
//        wait(for: [sessionExpectation], timeout: 10)
//    }
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

        await fulfillment(of: [startExpectation], timeout: 10)
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

        wait(for: [alertExpectation], timeout: 10)
    }

// TODO: Fix this in the ui test pr to not use the default notification center
//    @MainActor
//    func test_signUp_onFxASuccess_updatesSession() {
//        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")!
//        let viewModel = subject()
//
//        let sessionExpectation = expectation(description: "published error event")
//
//        NotificationCenter.default.publisher(
//            for: .userLoggedIn
//        ).sink { notification in
//            guard let session = notification.object as? SharedPocketKit.Session  else {
//                XCTFail("Session did not exist in notification center")
//                return
//            }
//            XCTAssertEqual(session.guid, "test-guid")
//            XCTAssertEqual(session.accessToken, "test-access-token")
//            XCTAssertEqual(session.userIdentifier, "test-id")
//            sessionExpectation.fulfill()
//        }.store(in: &subscriptions)
//
//        viewModel.signUp()
//
//        wait(for: [sessionExpectation], timeout: 10)
//    }
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

        await fulfillment(of: [offlineExpectation], timeout: 10)
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

        await fulfillment(of: [offlineExpectation, onlineExpectation], timeout: 10, enforceOrder: true)
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

        await fulfillment(of: [offlineExpectation], timeout: 10)
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

        await fulfillment(of: [offlineExpectation, onlineExpectation], timeout: 10, enforceOrder: true)
    }
}

extension LoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
