// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Pocket


class AuthorizationServiceTests: XCTestCase {
    var session: MockURLSession!
    var task: MockURLSessionDataTask!

    override func setUp() {
        session = MockURLSession()
        task = MockURLSessionDataTask()
    }

    func test_authorize_sendsPostRequestWithCorrectParameters() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            completionHandler(nil, .ok, nil)
            return self.task
        }

        authorize { _ in
            let calls = self.session.dataTaskCalls
            XCTAssertEqual(calls.count, 1)
            XCTAssertEqual(calls[0].request.url?.path, "/v3/oauth/authorize")
            XCTAssertEqual(calls[0].request.httpMethod, "POST")
            XCTAssertEqual(calls[0].request.value(forHTTPHeaderField: "X-Accept"), "application/json")
            XCTAssertEqual(calls[0].request.value(forHTTPHeaderField: "Content-Type"), "application/json")

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let body = try! decoder.decode(
                AuthorizeRequest.self,
                from: calls[0].request.httpBody!
            )

            XCTAssertEqual(body, AuthorizeRequest(
                username: "test@example.com",
                password: "super-secret-password",
                consumerKey: "the-consumer-key",
                grantType: "credentials",
                account: true
            ))
        }

        XCTAssertEqual(self.task.resumeCalls, 1)
    }

    func test_authorize_whenServerRespondsWith200_invokesCompletionWithAccessToken() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )

            let responseBody = """
            {
                "access_token":"the-access-token",
                "username":"test@example.com",
                "account": {
                    "firstName":"test",
                    "lastName":"user"
                }
            }
            """.data(using: .utf8)!

            completionHandler(
                responseBody,
                response,
                nil
            )
            return self.task
        }

        authorize { result in
            guard case .success(let token) = result else {
                XCTFail("Unexpected result: \(result). Expected success")
                return
            }

            XCTAssertEqual(token.accessToken, "the-access-token")
        }
    }

    func test_authorize_when200AndDataIsNil_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )

            completionHandler(nil, response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .invalidResponse = error else {
                XCTFail("Unexpected error \(error). Expected invalid response")
                return
            }
        }
    }

    func test_authorize_when200AndResponseDoesNotContainAccessToken_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "Pocket"]
            )

            completionHandler("no-access_token=lol".data(using: .utf8), response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .invalidResponse = error else {
                XCTFail("Unexpected error \(error). Expected invalid response")
                return
            }
        }
    }

    func test_authorize_whenStatusIs300_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(url: request.url, statusCode: 300)
            completionHandler(Data(), response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .unexpectedRedirect = error else {
                XCTFail("Unexpected error \(error). Expected unexpectedRedirect")
                return
            }

        }
    }

    func test_authorize_whenErrorIsNotNil_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            completionHandler(nil, nil, ExampleError.anError)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .generic(let internalError) = error else {
                XCTFail("Unexpected error: \(error). Expected generic error")
                return
            }

            XCTAssertEqual(internalError as? ExampleError, ExampleError.anError)
        }
    }

    func test_authorize_whenStatusIs400_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(url: request.url, statusCode: 400)
            completionHandler(nil, response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .badRequest = error else {
                XCTFail("Unexpected error: \(error). Expected generic error")
                return
            }
        }
    }

    func test_authorize_whenStatusIs401_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(url: request.url, statusCode: 401)
            completionHandler(nil, response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .invalidCredentials = error else {
                XCTFail("Unexpected error: \(error). Expected invalid credentials error")
                return
            }
        }
    }

    func test_authorize_whenStatusIs500_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(url: request.url, statusCode: 500)
            completionHandler(nil, response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .serverError = error else {
                XCTFail("Unexpected error: \(error). Expected server error")
                return
            }
        }
    }

    func test_authorize_whenStatusIs9001_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(url: request.url, statusCode: 9001)
            completionHandler(nil, response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .unexpectedError = error else {
                XCTFail("Unexpected error: \(error). Expected an unexpected error")
                return
            }
        }
    }

    func test_authorize_whenSourceHeaderIsInvalid_invokesCompletionWithError() {
        session.stubDataTaskWithCompletion { request, completionHandler in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: "1.1",
                headerFields: ["X-Source": "not-Pocket"]
            )

            completionHandler(nil, response, nil)
            return self.task
        }

        authorize { result in
            guard case .failure(let error) = result else {
                XCTFail("Unexpected result: \(result). Expected failure")
                return
            }

            guard case .invalidSource = error else {
                XCTFail("Unexpected error: \(error). Expected invalidSource")
                return
            }
        }
    }

    private func authorize(assertions: @escaping (Result<AuthorizeResponse, AuthorizationClient.Error>) -> ()) {
        let service = AuthorizationClient(consumerKey: "the-consumer-key", session: session)
        let done = expectation(description: "finished authorization request")
        service.authorize(
            username: "test@example.com",
            password: "super-secret-password"
        ) { result in
            assertions(result)
            done.fulfill()
        }
        waitForExpectations(timeout: 1.0)
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
