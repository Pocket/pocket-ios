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
        let mockTracker = MockTracker()
        authorizationClient = AuthorizationClient(consumerKey: "the-consumer-key", adjustSignupEventToken: "token", tracker: mockTracker) { (_, _, completion) in
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
        await viewModel.authenticate()

        await fulfillment(of: [startExpectation], timeout: 2)
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

        viewModel.authenticate()

        wait(for: [alertExpectation], timeout: 2)
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

        await viewModel.authenticate()

        await fulfillment(of: [offlineExpectation], timeout: 2)
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

        await viewModel.authenticate()
        networkPathMonitor.update(status: .satisfied)

        await fulfillment(of: [offlineExpectation, onlineExpectation], timeout: 2, enforceOrder: true)
    }
}

extension LoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
