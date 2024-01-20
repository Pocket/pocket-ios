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
        super.setUp()
        mockAuthenticationSession = MockAuthenticationSession()
        client = AuthorizationClient(consumerKey: "the-consumer-key", adjustSignupEventToken: "token") { (_, _, completion) in
            self.mockAuthenticationSession.completionHandler = completion
            return self.mockAuthenticationSession
        }

        mockAuthenticationSession.stubStart {
            let url = self.mockAuthenticationSession.url
            let error = self.mockAuthenticationSession.error
            self.mockAuthenticationSession.completionHandler?(url, error)
            return true
        }
    }
}

extension AuthorizationClientTests {
    func test_logIn_onSuccess_returnsAccessTokenAndUserIdentifier() async throws {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")
        let response = try await client.authenticate(from: self)
        XCTAssertEqual(response.guid, "test-guid")
        XCTAssertEqual(response.accessToken, "test-access-token")
        XCTAssertEqual(response.userIdentifier, "test-id")
    }

    func test_logIn_onSessionError_throwsErrorFromAuthenticationSession() async {
        mockAuthenticationSession.error = FakeError.error
        do {
            _ = try await client.authenticate(from: self)
            XCTFail("Expected to throw error, but didn't")
        } catch {
            XCTAssertTrue(error is AuthorizationClient.Error)
            XCTAssertEqual(error as? AuthorizationClient.Error, .other(FakeError.error))
        }
    }

    func test_logIn_onInvalidRedirect_throwsInvalidRedirectError() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa")!
        do {
            _ = try await client.authenticate(from: self)
            XCTFail("Expected to throw error, but didn't")
        } catch {
            XCTAssertTrue(error is AuthorizationClient.Error)
            XCTAssertEqual(error as? AuthorizationClient.Error, .invalidRedirect)
        }
    }

    func test_logIn_startsOnlyOneSession() async {
        mockAuthenticationSession.url = URL(string: "pocket://fxa?guid=test-guid&access_token=test-access-token&id=test-id")

        let expectSessionStart = expectation(description: "expected session start")
        expectSessionStart.expectedFulfillmentCount = 2
        expectSessionStart.isInverted = true
        mockAuthenticationSession.stubStart {
            expectSessionStart.fulfill()
            return true
        }
        let expectFirstClientStarted = expectation(description: "started client login")
        expectFirstClientStarted.expectedFulfillmentCount = 1

        Task {
            do {
                expectFirstClientStarted.fulfill()
                _ = try await self.client.authenticate(from: self)
            } catch {
                XCTFail("Should not have thrown an error \(error)")
            }
        }

        Task {
            do {
                // wait for our first task to have started before we try the one that should fail.
                await fulfillment(of: [expectFirstClientStarted], timeout: 10)
                _ = try await self.client.authenticate(from: self)
                XCTFail("Expected to throw error, but didn't")
            } catch {
                XCTAssertTrue(error is AuthorizationClient.Error)
                XCTAssertEqual(error as? AuthorizationClient.Error, .alreadyAuthenticating)
            }
        }

        await fulfillment(of: [expectSessionStart], timeout: 10)
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
