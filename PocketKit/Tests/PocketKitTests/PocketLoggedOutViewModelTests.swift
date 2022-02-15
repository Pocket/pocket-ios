import XCTest
@testable import PocketKit
import Combine


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

    func test_logIn_publishesNewSessionWithCorrectURL() {
        viewModel = PocketLoggedOutViewModel(consumerKey: "test-consumer-key", sessionType: MockAuthenticationSession.self)

        let sessionExpectation = expectation(description: "published new session")
        viewModel.session.sink { session in
            let session = session as? MockAuthenticationSession
            XCTAssertNotNil(session)
            XCTAssertNotNil(session?.url)
            XCTAssertEqual(session?.scheme, "pocket")
            XCTAssertEqual(session?.prefersEphemeralWebBrowserSession, true)

            let components = URLComponents(url: session!.url, resolvingAgainstBaseURL: false)
            XCTAssertEqual(components?.path, "/login")
            XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "consumer_key" })?.value, "test-consumer-key")
            XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "redirect_uri" })?.value, "pocket://fxa")
            XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "utm_source" })?.value, "ios")

            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [sessionExpectation], timeout: 1)
    }

    func test_logIn_whenErrorOccurs_sendsErrorEvent() {
        viewModel = PocketLoggedOutViewModel(consumerKey: "test-consumer-key", sessionType: MockErrorAuthenticationSession.self)

        let sessionExpectation = expectation(description: "published new session")
        viewModel.session.sink { session in
            _ = session.start()
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .error = event else {
                XCTFail("Expected error event, but got \(event)")
                return
            }
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [sessionExpectation, eventExpectation], timeout: 1)
    }

    func test_logIn_onSuccess_sendsLoginEvent() {
        viewModel = PocketLoggedOutViewModel(consumerKey: "test-consumer-key", sessionType: MockAuthenticationSession.self)

        let sessionExpectation = expectation(description: "published new session")
        viewModel.session.sink { session in
            _ = session.start()
            sessionExpectation.fulfill()
        }.store(in: &subscriptions)

        let eventExpectation = expectation(description: "published error event")
        viewModel.events.sink { event in
            guard case .login(let token) = event else {
                XCTFail("Expected login event, but got \(event) instead")
                return
            }

            XCTAssertEqual(token, "test-access-token")
            eventExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.logIn()
        wait(for: [sessionExpectation, eventExpectation], timeout: 1)
    }
}
