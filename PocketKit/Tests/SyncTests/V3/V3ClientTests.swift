// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Sync

// swiftlint:disable force_try
final class V3ClientTests: XCTestCase {
    let consumerKey = "the-consumer-key"
    let deviceIdentifier = "never-gonna-give-you-up"
    let token = "the-cool-apns-token"

    var urlSession: MockURLSession!
    var sessionProvider: MockSessionProvider!
    var client: V3Client!
    var session: MockSession!

    override func setUp() {
        try super.setUp()
        urlSession = MockURLSession()
        session = MockSession()
        sessionProvider = MockSessionProvider(session: session)
        client = V3Client(sessionProvider: sessionProvider, consumerKey: consumerKey, urlSession: urlSession)
    }
}

// MARK: Session Helper
extension V3ClientTests {
    func test_fallbackSession_usesPassedInSession() {
        do {
            var passedSession = MockSession()
            passedSession.accessToken = "the-better-access-token"
            passedSession.guid = "the-cool-guid"
            let receivedSession = try client.fallbackSession(session: passedSession)
            XCTAssertEqual(receivedSession.guid, passedSession.guid)
            XCTAssertEqual(receivedSession.accessToken, passedSession.accessToken)
        } catch {
            XCTFail("fallbackSession() should not throw an error in this context: \(error)")
        }
    }

    func test_fallbackSession_usesFallbackSession() {
        do {
            let receivedSession = try client.fallbackSession(session: nil)
            XCTAssertEqual(receivedSession.guid, session.guid)
            XCTAssertEqual(receivedSession.accessToken, session.accessToken)
        } catch {
            XCTFail("fallbackSession() should not throw an error in this context: \(error)")
        }
    }
}

// MARK: Register Device for Identifier
extension V3ClientTests {
    func test_registerDeviceFor_sendsPostRequestWithCorrectParameters() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            return (Data(), URLResponse())
        }

        _ = try? await registerDeviceForIdentifer()
        let calls = self.urlSession.dataTaskCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].request.url?.path, "/v3/push/register")
        XCTAssertEqual(calls[0].request.httpMethod, "POST")
        XCTAssertEqual(calls[0].request.value(forHTTPHeaderField: "X-Accept"), "application/json")
        XCTAssertEqual(calls[0].request.value(forHTTPHeaderField: "Content-Type"), "application/json")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let body = try! decoder.decode(
            RegisterPushTokenRequest.self,
            from: calls[0].request.httpBody!
        )

        XCTAssertEqual(body, RegisterPushTokenRequest(
            accessToken: session.accessToken,
            consumerKey: consumerKey,
            guid: session.guid,
            deviceIdentifier: deviceIdentifier,
            pushType: "alpha",
            token: token
        ))
    }

    func test_registerDeviceFor_whenServerRespondsWith200_invokesCompletionWithDeviceToken() async {
        urlSession.stubData { [weak self] (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!

            let responseBody = """
                {
                    "status": 1,
                    "error": 0,
                    "token": {
                        "device_identifier": "\(self!.deviceIdentifier)",
                        "expires_at": 1671602670
                    }
                }
                """.data(using: .utf8)!

            return (responseBody, response)
        }

        do {
            let response = try await registerDeviceForIdentifer()
            XCTAssertEqual(response.token.deviceIdentifier, deviceIdentifier)
            XCTAssertEqual(response.token.expiresAt, 1671602670)
            XCTAssertEqual(response.status, 1)
            XCTAssertEqual(response.error, 0)
        } catch {
            XCTFail("registerDeviceForIdentifer() should not throw an error in this context: \(error)")
        }
    }

    func test_registerDeviceFor_when200AndDataIsEmpty_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!

            return (Data(), response)
        }

        do {
            _ = try await registerDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.invalidResponse = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid response")
                return
            }
        }
    }

    func test_registerDeviceFor_whenStatusIs400_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!
            return (Data(), response)
        }

        do {
            _ = try await registerDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.badRequest = error else {
                XCTFail("Unexpected error: \(error). Expected a bad request")
                return
            }
        }
    }

    func test_registerDeviceForIdentifer_whenStatusIs500_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!
            return (Data(), response)
        }

        do {
            _ = try await registerDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.serverError = error else {
                XCTFail("Unexpected error: \(error). Expected a server error")
                return
            }
        }
    }

    func test_registerDeviceForIdentifer_whenSourceHeaderIsInvalid_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "not-Pocket"]
            )!

            return (Data(), response)
        }

        do {
            _ = try await registerDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.invalidSource = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid source")
                return
            }
        }
    }

    private func registerDeviceForIdentifer() async throws -> RegisterPushTokenResponse {
        return try await client.registerPushToken(
            for: deviceIdentifier,
            pushType: .alpha,
            token: token,
            session: session
        )!
    }
}

// MARK: De-register Device for Identifier
extension V3ClientTests {
    func test_deregisterDeviceFor_sendsPostRequestWithCorrectParameters() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            return (Data(), URLResponse())
        }

        _ = try? await deregisterDeviceForIdentifer()
        let calls = self.urlSession.dataTaskCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].request.url?.path, "/v3/push/deregister")
        XCTAssertEqual(calls[0].request.httpMethod, "POST")
        XCTAssertEqual(calls[0].request.value(forHTTPHeaderField: "X-Accept"), "application/json")
        XCTAssertEqual(calls[0].request.value(forHTTPHeaderField: "Content-Type"), "application/json")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let body = try! decoder.decode(
            DeregisterPushTokenRequest.self,
            from: calls[0].request.httpBody!
        )

        XCTAssertEqual(body, DeregisterPushTokenRequest(
            accessToken: session.accessToken,
            consumerKey: consumerKey,
            guid: session.guid,
            deviceIdentifier: deviceIdentifier,
            pushType: "alpha"
        ))
    }

    func test_deregisterDeviceFor_whenServerRespondsWith200_invokesCompletionWithDeviceToken() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!

            let responseBody = """
                {
                    "status": 1,
                    "error": 0,
                }
                """.data(using: .utf8)!

            return (responseBody, response)
        }

        do {
            let response = try await deregisterDeviceForIdentifer()
            XCTAssertEqual(response.status, 1)
            XCTAssertEqual(response.error, 0)
        } catch {
            XCTFail("deregisterDeviceForIdentifer() should not throw an error in this context: \(error)")
        }
    }

    func test_deregisterDeviceFor_when200AndDataIsEmpty_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!

            return (Data(), response)
        }

        do {
            _ = try await deregisterDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.invalidResponse = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid response")
                return
            }
        }
    }

    func test_deregisterDeviceFor_whenStatusIs400_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 400,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!
            return (Data(), response)
        }

        do {
            _ = try await deregisterDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.badRequest = error else {
                XCTFail("Unexpected error: \(error). Expected a bad request")
                return
            }
        }
    }

    func test_deregisterDeviceForIdentifer_whenStatusIs500_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )!
            return (Data(), response)
        }

        do {
            _ = try await deregisterDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.serverError = error else {
                XCTFail("Unexpected error: \(error). Expected a server error")
                return
            }
        }
    }

    func test_deregisterDeviceForIdentifer_whenSourceHeaderIsInvalid_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "not-Pocket"]
            )!

            return (Data(), response)
        }

        do {
            _ = try await deregisterDeviceForIdentifer()
        } catch {
            guard case V3Client.Error.invalidSource = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid source")
                return
            }
        }
    }

    private func deregisterDeviceForIdentifer() async throws -> DeregisterPushTokenResponse {
        return try await client.deregisterPushToken(
            for: deviceIdentifier,
            pushType: .alpha,
            session: session
        )!
    }
}
// swiftlint:enable force_try
