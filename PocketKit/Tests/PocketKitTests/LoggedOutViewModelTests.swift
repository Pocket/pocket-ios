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
    private var featureFlags: MockFeatureFlagService!
    private var refreshCoordinator: RefreshCoordinator!

    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        tracker = MockTracker()
        authorizationClient = AuthorizationClient(consumerKey: "the-consumer-key", adjustSignupEventToken: "token", tracker: tracker) { (_, _, completion) in
            self.mockAuthenticationSession.completionHandler = completion
            return self.mockAuthenticationSession
        }
        appSession = AppSession(keychain: MockKeychain(), groupID: "group.com.ideashower.ReadItLaterPro")
        networkPathMonitor = MockNetworkPathMonitor()

        mockAuthenticationSession = MockAuthenticationSession()
        userManagementService = MockUserManagementService()
        featureFlags = MockFeatureFlagService()
        featureFlags.stubIsAssigned { _, _ in
            return true
        }
        let notificationCenter = NotificationCenter()
        let userDefaults = UserDefaults(suiteName: "HomeViewModelTests")
        let lastRefresh = UserDefaultsLastRefresh(defaults: userDefaults!)
        lastRefresh.reset()
        let mockSource = MockSource()
        mockSource.stubAllFeatureFlags {}
        refreshCoordinator = FeatureFlagsRefreshCoordinator(notificationCenter: notificationCenter, taskScheduler: MockBGTaskScheduler(), appSession: appSession, source: mockSource, lastRefresh: lastRefresh)

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

    @MainActor
    func subject(
        authorizationClient: AuthorizationClient? = nil,
        appSession: AppSession? = nil,
        networkPathMonitor: NetworkPathMonitor? = nil,
        tracker: Tracker? = nil,
        featureFlags: FeatureFlagServiceProtocol? = nil,
        refreshCoordinator: RefreshCoordinator? = nil
    ) -> LoggedOutViewModel {
        let viewModel = LoggedOutViewModel(
            appSession: appSession ?? self.appSession,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            tracker: tracker ?? self.tracker,
            userManagementService: userManagementService ?? self.userManagementService,
            featureFlags: featureFlags ?? self.featureFlags,
            refreshCoordinator: refreshCoordinator ?? self.refreshCoordinator,
            accessService: PocketAccessService(
                authorizationClient: self.authorizationClient,
                appSession: self.appSession,
                tracker: self.tracker,
                client: MockV3Client()
            )
        )
        return viewModel
    }
}

extension LoggedOutViewModelTests {
    @MainActor
    func test_logIn_withExistingSession_doesNotAttemptAuthentication() async {
        appSession.setCurrentSession(
            Session(
                guid: "mock-guid",
                accessToken: "mock-access-token",
                userIdentifier: "mock-user-identifier"
            )
        )

        let startExpectation = expectation(description: "expected start to not be called")
        startExpectation.isInverted = true
        mockAuthenticationSession.stubStart {
            startExpectation.fulfill()
            return true
        }

        let viewModel = subject()
        viewModel.signUpOrSignIn()

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

        viewModel.signUpOrSignIn()

        wait(for: [alertExpectation], timeout: 2)
    }
}

extension LoggedOutViewModelTests {
    @MainActor
    func test_logIn_whenOffline_setsPresentOfflineViewToTrue() async {
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        let offlineExpectation = expectation(description: "update presentOfflineView")
        viewModel.$isPresentingOfflineView.dropFirst().sink { present in
            XCTAssertTrue(present)
            offlineExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUpOrSignIn()

        await fulfillment(of: [offlineExpectation], timeout: 2)
    }

    @MainActor
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

        viewModel.signUpOrSignIn()
        networkPathMonitor.update(status: .satisfied)

        await fulfillment(of: [offlineExpectation, onlineExpectation], timeout: 2, enforceOrder: true)
    }
}
