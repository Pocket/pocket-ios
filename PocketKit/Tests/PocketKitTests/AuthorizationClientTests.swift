// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit
import AuthenticationServices


class AuthorizationClientTests: XCTestCase {
    var urlSession: MockURLSession!
    var client: AuthorizationClient!

    override func setUp() {
        urlSession = MockURLSession()
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )
    }
}

extension AuthorizationClientTests {
    func test_logIn_buildsCorrectRequest() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )

        let (request, _) = await client.logIn(from: self)
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.callbackURLScheme, "pocket")

        let components = URLComponents(url: request!.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.path, "/login")
        XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "consumer_key" })?.value, "the-consumer-key")
        XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "redirect_uri" })?.value, "pocket://fxa")
        XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "utm_source" })?.value, "ios")
    }

    func test_logIn_onSuccess_returnsAccessTokenAndUserIdentifier() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )

        let (_, response) = await client.logIn(from: self)
        XCTAssertEqual(response?.guid, "test-guid")
        XCTAssertEqual(response?.accessToken, "test-access-token")
        XCTAssertEqual(response?.userIdentifier, "test-id")
    }

    func test_logIn_onError_returnsNilResponse() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockErrorAuthenticationSession.self
        )

        let (_, response) = await client.logIn(from: self)
        XCTAssertNil(response)
    }
}

extension AuthorizationClientTests {
    func test_signUp_buildsCorrectRequest() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )

        let (request, _) = await client.signUp(from: self)
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.callbackURLScheme, "pocket")

        let components = URLComponents(url: request!.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.path, "/signup")
        XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "consumer_key" })?.value, "the-consumer-key")
        XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "redirect_uri" })?.value, "pocket://fxa")
        XCTAssertEqual(components?.queryItems?.first(where: { $0.name == "utm_source" })?.value, "ios")
    }

    func test_signUp_onSuccess_returnsAccessTokenAndUserIdentifier() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockAuthenticationSession.self
        )

        let (_, response) = await client.signUp(from: self)
        XCTAssertEqual(response?.guid, "test-guid")
        XCTAssertEqual(response?.accessToken, "test-access-token")
        XCTAssertEqual(response?.userIdentifier, "test-id")
    }

    func test_signUp_onError_returnsNilResponse() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            authenticationSession: MockErrorAuthenticationSession.self
        )

        let (_, response) = await client.signUp(from: self)
        XCTAssertNil(response)
    }
}

extension AuthorizationClientTests: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIWindow()
    }
}

extension HTTPURLResponse {
    convenience init?(url: URL?, statusCode: Int) {
        self.init(
            url: url ?? URL(string: "http://example.com")!,
            statusCode: statusCode,
            httpVersion: "1.1",
            headerFields: [:]
        )
    }
}

extension URLResponse {
    class var ok: HTTPURLResponse? {
        return HTTPURLResponse(url: nil, statusCode: 200)
    }
}

enum ExampleError: Error {
    case anError
}
