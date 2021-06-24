// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


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

    func authorize(username: String, password: String, completion: @escaping (Result<AuthorizeResponse, Error>) -> ()) {
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

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.generic(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unexpectedError))
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                guard let source = httpResponse.value(forHTTPHeaderField: "X-Source"),
                      source == "Pocket" else {
                    completion(.failure(.invalidSource))
                    return
                }

                let decoder = JSONDecoder()
                guard let data = data,
                      let response = try? decoder.decode(AuthorizeResponse.self, from: data) else {
                    completion(.failure(.invalidResponse))
                    return
                }

                completion(.success(response))
                return
            case 300...399:
                completion(.failure(.unexpectedRedirect))
                return
            case 400:
                completion(.failure(.badRequest))
                return
            case 401...499:
                completion(.failure(.invalidCredentials))
                return
            case 500...599:
                completion(.failure(.serverError))
                return
            default:
                completion(.failure(.unexpectedError))
                return
            }
        }

        task.resume()
    }
}
