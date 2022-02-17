import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices


class PocketLoggedOutViewModelTests: XCTestCase {
    private var viewModel: PocketLoggedOutViewModel!
    private var sessionController: MockSessionController!
    private var subscriptions: Set<AnyCancellable>!
    private let events = PocketEvents()

    @Published
    var foo: String = ""

    override func setUp() {
        sessionController = MockSessionController()
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }

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
            sessionController: sessionController,
            events: events
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
            sessionController: sessionController,
            events: events
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

    func test_logIn_onFxASuccess_sendsLoginEvent() {
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
            sessionController: sessionController,
            events: events
        )
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        events.sink { event in
            guard case .signedIn = event else {
                XCTFail("Expected login event, but got \(event)")
                return
            }
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [eventExpectation], timeout: 1)
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
            sessionController: sessionController,
            events: events
        )
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        events.sink { event in
            XCTAssertEqual(self.sessionController.updateCalls.count, 1)
            let lastSession = self.sessionController.updateCalls.last?.session
            XCTAssertEqual(lastSession?.guid, "sample-guid")
            XCTAssertEqual(lastSession?.accessToken, "test-access-token")
            XCTAssertEqual(lastSession?.userIdentifier, "")
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [eventExpectation], timeout: 1)
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
