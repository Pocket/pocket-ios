import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices


class PocketLoggedOutViewModelTests: XCTestCase {
    private var viewModel: PocketLoggedOutViewModel!
    private var subscriptions: Set<AnyCancellable>!
    private var appSession: AppSession!

    @Published
    var foo: String = ""

    override func setUp() {
        appSession = AppSession(keychain: MockKeychain())
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }
}

extension PocketLoggedOutViewModelTests {
    func test_logIn_onGUIDError_setsPresentedAlert() {
        let urlSession = MockURLSession()
        urlSession.stubData { _ in
            throw FakeError.error
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )

        viewModel = PocketLoggedOutViewModel(
            authorizationClient: client,
            appSession: appSession
        )
        viewModel.contextProvider = self

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_logIn_onFxAError_setsPresentedAlert() {
        let urlSession = MockURLSession()
        urlSession.stubData { request in
            self.validGUIDResponse(for: request)
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(
            authorizationClient: client,
            appSession: appSession
        )

        viewModel.contextProvider = self

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_logIn_onFxASuccess_updatesSession() {
        let urlSession = MockURLSession()
        urlSession.stubData { request in
            self.validGUIDResponse(for: request)
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(
            authorizationClient: client,
            appSession: appSession
        )
        viewModel.contextProvider = self

        let sessionExpectation = expectation(description: "published error event")
        appSession.$currentSession.dropFirst().sink { session in
            XCTAssertEqual(session?.guid, "sample-guid")
            XCTAssertEqual(session?.accessToken, "test-access-token")
            XCTAssertEqual(session?.userIdentifier, "")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension PocketLoggedOutViewModelTests {
    func test_signUp_onGUIDError_setsPresentedAlert() {
        let urlSession = MockURLSession()
        urlSession.stubData { _ in
            throw FakeError.error
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )

        viewModel = PocketLoggedOutViewModel(
            authorizationClient: client,
            appSession: appSession
        )
        viewModel.contextProvider = self

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_signUp_onFxAError_setsPresentedAlert() {
        let urlSession = MockURLSession()
        urlSession.stubData { request in
            self.validGUIDResponse(for: request)
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(
            authorizationClient: client,
            appSession: appSession
        )

        viewModel.contextProvider = self

        let alertExpectation = expectation(description: "set presented alert")
        viewModel.$presentedAlert.dropFirst().sink { alert in
            XCTAssertNotNil(alert)
            alertExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [alertExpectation], timeout: 1)
    }

    func test_signUp_onFxASuccess_updatesSession() {
        let urlSession = MockURLSession()
        urlSession.stubData { request in
            self.validGUIDResponse(for: request)
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(
            authorizationClient: client,
            appSession: appSession
        )
        viewModel.contextProvider = self

        let sessionExpectation = expectation(description: "published error event")
        appSession.$currentSession.dropFirst().sink { session in
            XCTAssertEqual(session?.guid, "sample-guid")
            XCTAssertEqual(session?.accessToken, "test-access-token")
            XCTAssertEqual(session?.userIdentifier, "")
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.signUp()
        wait(for: [sessionExpectation], timeout: 1)
    }
}

extension PocketLoggedOutViewModelTests {
    private func validGUIDResponse(for request: URLRequest) -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: ["X-Source": "Pocket"]
        )!

        let responseBody = """
        {
            "guid": "sample-guid"
        }
        """.data(using: .utf8)!

        return (responseBody, response)
    }
}

extension PocketLoggedOutViewModelTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}
