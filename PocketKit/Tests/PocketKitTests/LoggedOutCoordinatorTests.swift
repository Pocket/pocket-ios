import XCTest
@testable import PocketKit


class LoggedOutCoordinatorTests: XCTestCase {
    private var coordinator: LoggedOutCoordinator!
    private var viewModel: MockLoggedOutViewModel!
    private var authenticationSession: MockAuthenticationSession!

    override func setUp() {
        authenticationSession = MockAuthenticationSession(
            url: URL(string: "https://getpocket.com")!,
            callbackURLScheme: nil,
            completionHandler: { _, _ in }
        )
        viewModel = MockLoggedOutViewModel()
        coordinator = LoggedOutCoordinator(viewModel: viewModel)
    }

    func test_authenticationSession_onReceiveValue_updatesAndStartsSession() {
        viewModel._session.send(authenticationSession)

        XCTAssertTrue(authenticationSession.presentationContextProvider === coordinator)
        XCTAssertEqual(authenticationSession.startCalls, 1)
    }
}
