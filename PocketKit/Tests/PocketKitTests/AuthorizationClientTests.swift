// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit
import AuthenticationServices


class AuthorizationClientTests: XCTestCase {
    var client: AuthorizationClient!
    var mockAuthenticationSession: MockAuthenticationSession!

    override func setUp() {
        mockAuthenticationSession = MockAuthenticationSession()
        client = AuthorizationClient(consumerKey: "the-consumer-key") { (_, _, completion) in
            self.mockAuthenticationSession.completionHandler = completion
            return self.mockAuthenticationSession
        }
    }
}

extension AuthorizationClientTests {
    func test_logIn_onSuccess_returnsAccessTokenAndUserIdentifier() async throws {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")
        let response = try await client.logIn(from: self)
        XCTAssertEqual(response.guid, "test-guid")
        XCTAssertEqual(response.accessToken, "test-access-token")
        XCTAssertEqual(response.userIdentifier, "test-id")
    }

    func test_logIn_onSessionError_throwsErrorFromAuthenticationSession() async {
        mockAuthenticationSession.error = FakeError.error
        do {
            _ = try await client.logIn(from: self)
            XCTFail("Expected to throw error, but didn't")
        } catch {
            XCTAssertTrue(error is AuthorizationClient.Error)
            XCTAssertEqual(error as? AuthorizationClient.Error, .other(FakeError.error))
        }
    }

    func test_logIn_onInvalidRedirect_throwsInvalidRedirectError() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        do {
            _ = try await client.logIn(from: self)
            XCTFail("Expected to throw error, but didn't")
        } catch {
            XCTAssertTrue(error is AuthorizationClient.Error)
            XCTAssertEqual(error as? AuthorizationClient.Error, .invalidRedirect)
        }
    }
}

extension AuthorizationClientTests {
    func test_signUp_onSuccess_returnsAccessTokenAndUserIdentifier() async throws {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")
        let response = try await client.signUp(from: self)
        XCTAssertEqual(response.guid, "test-guid")
        XCTAssertEqual(response.accessToken, "test-access-token")
        XCTAssertEqual(response.userIdentifier, "test-id")
    }

    func test_signUp_onSessionError_throwsErrorFromAuthenticationSession() async {
        mockAuthenticationSession.error = FakeError.error
        do {
            _ = try await client.signUp(from: self)
            XCTFail("Expected to throw error, but didn't")
        } catch {
            XCTAssertTrue(error is AuthorizationClient.Error)
            XCTAssertEqual(error as? AuthorizationClient.Error, .other(FakeError.error))
        }
    }

    func test_signUp_onInvalidRedirect_throwsInvalidRedirectError() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        do {
            _ = try await client.signUp(from: self)
            XCTFail("Expected to throw error, but didn't")
        } catch {
            XCTAssertTrue(error is AuthorizationClient.Error)
            XCTAssertEqual(error as? AuthorizationClient.Error, .invalidRedirect)
        }
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
