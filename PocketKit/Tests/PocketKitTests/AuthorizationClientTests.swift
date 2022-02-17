// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit
import AuthenticationServices


class AuthorizationServiceTests: XCTestCase {
    var urlSession: MockURLSession!
    var client: AuthorizationClient!

    override func setUp() {
        urlSession = MockURLSession()
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockAuthenticationSession.self
        )
    }
}

// MARK: - GUID
extension AuthorizationServiceTests {
    func test_guid_sendsGETRequestWithCorrectParameters() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let data = "sample-guid".data(using: .utf8)!
            return (data, .ok!)
        }

        _ = try? await client.requestGUID()
        let calls = self.urlSession.dataTaskCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls[0].request.url?.path, "/v3/guid")
        XCTAssertEqual(calls[0].request.httpMethod, "GET")
    }

    func test_guid_whenServerRespondsWith200_invokesCompletionWithGUID() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
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

        do {
            let guid = try await client.requestGUID()
            XCTAssertEqual(guid, "sample-guid")
        } catch {
            XCTFail("requestGUID() should not throw an error in this context: \(error)")
        }
    }

    func test_guid_when200AndDataIsEmpty_invokesCompletionWithError() async {
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
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.invalidResponse = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid response")
                return
            }
        }
    }

    func test_guid_when200AndResponseDoesNotContainAccessToken_invokesCompletionWithError() async {
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
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.invalidResponse = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid response")
                return
            }
        }
    }

    func test_guid_whenStatusIs300_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(url: request.url, statusCode: 300)!
            return (Data(), response)
        }

        do {
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.unexpectedRedirect = error else {
                XCTFail("Unexpected error: \(error). Expected an unexpected redirect")
                return
            }
        }
    }

    func test_guid_whenErrorIsNotNil_invokesCompletionWithError() async {
        urlSession.stubData { _ throws -> (Data, URLResponse) in
            throw ExampleError.anError
        }
        
        do {
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.generic(let internalError) = error else {
                XCTFail("Unexpected error: \(error). Expected a generic error")
                return
            }
            
            XCTAssertEqual(internalError as? ExampleError, ExampleError.anError)
        }
    }

    func test_guid_whenStatusIs400_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(url: request.url, statusCode: 400)!
            return (Data(), response)
        }
        
        do {
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.badRequest = error else {
                XCTFail("Unexpected error: \(error). Expected a bad request")
                return
            }
        }
    }

    func test_guid_whenStatusIs401_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(url: request.url, statusCode: 401)!
            return (Data(), response)
        }

        do {
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.invalidCredentials = error else {
                XCTFail("Unexpected error: \(error). Expected invalid credentials")
                return
            }
        }
    }

    func test_guid_whenStatusIs500_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(url: request.url, statusCode: 500)!
            return (Data(), response)
        }

        do {
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.serverError = error else {
                XCTFail("Unexpected error: \(error). Expected a server error")
                return
            }
        }
    }

    func test_guid_whenStatusIs9001_invokesCompletionWithError() async {
        urlSession.stubData { (request) throws -> (Data, URLResponse) in
            let response = HTTPURLResponse(url: request.url!, statusCode: 9001)!
            return (Data(), response)
        }

        do {
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.unexpectedError = error else {
                XCTFail("Unexpected error: \(error). Expected an unexpected error")
                return
            }
        }
    }

    func test_guid_whenSourceHeaderIsInvalid_invokesCompletionWithError() async {
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
            _ = try await client.requestGUID()
        } catch {
            guard case AuthorizationClient.Error.invalidSource = error else {
                XCTFail("Unexpected error: \(error). Expected an invalid source")
                return
            }
        }
    }
}

extension AuthorizationServiceTests {
    func test_logIn_buildsCorrectRequest() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            urlSession: urlSession,
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
            urlSession: urlSession,
            authenticationSession: MockAuthenticationSession.self
        )

        let (_, response) = await client.logIn(from: self)
        XCTAssertEqual(response?.accessToken, "test-access-token")
        XCTAssertEqual(response?.userIdentifier, "")
    }

    func test_logIn_onError_returnsNilResponse() async {
        client = AuthorizationClient(
            consumerKey: "the-consumer-key",
            urlSession: urlSession,
            authenticationSession: MockErrorAuthenticationSession.self
        )

        let (_, response) = await client.logIn(from: self)
        XCTAssertNil(response)
    }
}

extension AuthorizationServiceTests: ASWebAuthenticationPresentationContextProviding {
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
