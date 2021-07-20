// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


private struct GUIDResponse: Decodable {
    let guid: String
}

public class AuthorizationClient {
    enum Error: Swift.Error {
        case invalidResponse
        case invalidSource
        case unexpectedRedirect
        case badRequest
        case invalidCredentials
        case serverError
        case unexpectedError
        case generic(Swift.Error)

        var localizedDescription: String {
            "Invalid email or password"
        }
    }

    enum Constants {
        static let baseURL = URL(
            string: ProcessInfo.processInfo.environment["POCKET_V3_BASE_URL"] ?? "https://getpocket.com"
        )!
    }

    private let session: URLSessionProtocol
    private let consumerKey: String

    init(consumerKey: String, session: URLSessionProtocol) {
        self.consumerKey = consumerKey
        self.session = session
    }
    
    func requestGUID() async throws -> String {
        guard let url = URL(
            string: "/v3/guid",
            relativeTo: AuthorizationClient.Constants.baseURL
        ) else {
            fatalError("Unable to construct guid URL")
        }
        
        let request = URLRequest(url: url)
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request, delegate: nil)
        } catch {
            throw Error.generic(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.unexpectedError
        }

        switch httpResponse.statusCode {
        case 200...299:
            guard let source = httpResponse.value(forHTTPHeaderField: "X-Source"),
                  source == "Pocket" else {
                      throw Error.invalidSource
            }

            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(GUIDResponse.self, from: data) else {
                throw Error.invalidResponse
            }

            return response.guid
        case 300...399:
            throw Error.unexpectedRedirect
        case 400:
            throw Error.badRequest
        case 401...499:
            throw Error.invalidCredentials
        case 500...599:
            throw Error.serverError
        default:
            throw Error.unexpectedError
        }
    }

    func authorize(
        guid: String,
        username: String,
        password: String
    ) async throws -> AuthorizeResponse {
        guard let authorizeURL = URL(
            string: "/v3/oauth/authorize",
            relativeTo: AuthorizationClient.Constants.baseURL
        ) else {
            fatalError("Unable to construct authorize URL")
        }

        var request = URLRequest(url: authorizeURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "X-Accept")

        let requestBody = AuthorizeRequest(
            guid: guid,
            username: username,
            password: password,
            consumerKey: consumerKey,
            grantType: "credentials",
            account: true
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try! encoder.encode(requestBody)
        request.httpMethod = "POST"
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request, delegate: nil)
        } catch {
            throw Error.generic(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.unexpectedError
        }

        switch httpResponse.statusCode {
        case 200...299:
            guard let source = httpResponse.value(forHTTPHeaderField: "X-Source"),
                  source == "Pocket" else {
                      throw Error.invalidSource
            }

            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(AuthorizeResponse.self, from: data) else {
                throw Error.invalidResponse
            }

            return response
        case 300...399:
            throw Error.unexpectedRedirect
        case 400:
            throw Error.badRequest
        case 401...499:
            throw Error.invalidCredentials
        case 500...599:
            throw Error.serverError
        default:
            throw Error.unexpectedError
        }
    }
}
