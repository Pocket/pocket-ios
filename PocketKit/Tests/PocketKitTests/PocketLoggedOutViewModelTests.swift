import XCTest
@testable import PocketKit
import Combine
import AuthenticationServices


class PocketLoggedOutViewModelTests: XCTestCase {
    private var viewModel: PocketLoggedOutViewModel!
    private var subscriptions: Set<AnyCancellable>!

    @Published
    var foo: String = ""

    override func setUp() {
        subscriptions = []
    }

    override func tearDown() {
        subscriptions = []
    }

    func test_logIn_onGUIDError_sendsErrorEvent() {
        let urlSession = MockURLSession()
        urlSession.stubData { _ in
            throw FakeError.error
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(authorizationClient: client)
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .error = event else {
                XCTFail("Expected error event, but got \(event)")
                return
            }
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [eventExpectation], timeout: 1)
    }

    func test_logIn_onFxAError_sendsErrorEvent() {
        let urlSession = MockURLSession()
        urlSession.stubData { request in
            self.validGUIDResponse(for: request)
        }

        let client = AuthorizationClient(
            consumerKey: "test-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )
        viewModel = PocketLoggedOutViewModel(authorizationClient: client)
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .error = event else {
                XCTFail("Expected error event, but got \(event)")
                return
            }
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [eventExpectation], timeout: 1)
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
        viewModel = PocketLoggedOutViewModel(authorizationClient: client)
        viewModel.contextProvider = self

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .login(let auth) = event else {
                XCTFail("Expected login event, but got \(event)")
                return
            }
            XCTAssertEqual(auth.guid, "sample-guid")
            XCTAssertEqual(auth.accessToken, "test-access-token")
            XCTAssertEqual(auth.userIdentifier, "1a2b3c4d5e6")
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
