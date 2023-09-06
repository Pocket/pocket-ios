// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import ApolloAPI
import Foundation
import SharedPocketKit

public extension ApolloClientProtocol {
    func fetch<Query: GraphQLQuery>(query: Query, queue: DispatchQueue = .global(qos: .utility), resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
        return fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely,
            contextIdentifier: nil,
            queue: queue,
            resultHandler: resultHandler
        )
    }

    func fetch<Query: GraphQLQuery>(query: Query, queue: DispatchQueue = .global(qos: .utility), filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) async throws -> GraphQLResult<Query.Data> {
        Log.debug("Requesting \(String(describing: query))", filename: filename, line: line, column: column, funcName: funcName)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GraphQLResult<Query.Data>, Error>) in
            _ = fetch(query: query, queue: queue) { result in
                switch result {
                case .failure(let error):
                    Self.handleServerError(error, filename: filename, line: line, column: column, funcName: funcName)
                    continuation.resume(throwing: error)
                case .success(let data):
                    guard let errors = data.errors,
                            !errors.isEmpty else {
                        Log.debug("Successful response of \(String(describing: query))", filename: filename, line: line, column: column, funcName: funcName)
                        continuation.resume(returning: data)
                        return
                    }
                    Log.warning("Error with query \(String(describing: query)) with errors \(String(describing: errors))", filename: filename, line: line, column: column, funcName: funcName)
                    // Even though we had errors, let's continue forward for now, it should be up to the individual query executor to use what data we could since GraphQL can return partial responses
                    continuation.resume(returning: data)
                }
            }
        }
    }

    func perform<Mutation: GraphQLMutation>(mutation: Mutation, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) async throws -> GraphQLResult<Mutation.Data> {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GraphQLResult<Mutation.Data>, Error>) in
            Log.debug("Requesting \(String(describing: mutation))", filename: filename, line: line, column: column, funcName: funcName)
            _ = perform(
                mutation: mutation,
                publishResultToStore: false,
                queue: .main
            ) { result in
                switch result {
                case .failure(let error):
                    Self.handleServerError(error, filename: filename, line: line, column: column, funcName: funcName)
                    continuation.resume(throwing: error)
                case .success(let data):
                    guard let errors = data.errors,
                            !errors.isEmpty else {
                        Log.debug("Successful response of \(String(describing: mutation))", filename: filename, line: line, column: column, funcName: funcName)
                        continuation.resume(returning: data)
                        return
                    }
                    Log.warning("Error with mutation \(String(describing: mutation)) with errors \(String(describing: errors))", filename: filename, line: line, column: column, funcName: funcName)
                    // Even though we had errors, let's continue forward for now, it should be up to the individual query executor to use what data we could since GraphQL can return partial responses
                    continuation.resume(returning: data)
                }
            }
        }
    }

    /// Takes a GraphQl response error and logs it to Sentry. If the error code belongs
    /// to a specified set of errors, also posts a notification containing the status code
    private static func handleServerError(_ error: Error,
                                          filename: String,
                                          line: Int,
                                          column: Int,
                                          funcName: String) {
        // Codes we wish to notify the user about
        let notifiableErrorCodes = [429, 500, 503]
        let skippableErrors = [403]

        guard let responseError = error as? ResponseCodeInterceptor.ResponseCodeError else {
            Log.capture(message: "GraphQl Error - unknown error.", filename: filename, line: line, column: column, funcName: funcName)
            return
        }

        Log.capture(
            message: "GraphQl Error - description: \(responseError.errorDescription ?? "no description found").",
            filename: filename,
            line: line,
            column: column,
            funcName: funcName
        )

        // If we've received an invalid response code from the server…
        if case .invalidResponseCode(let response, _) = responseError, let statusCode = response?.statusCode {
            // …and we shouldn't skip over the error…
            if skippableErrors.contains(statusCode) == false {
                // …then capture the error
                Log.capture(
                    message: "GraphQl Error - description: \(responseError.errorDescription ?? "no description found").",
                    filename: filename,
                    line: line,
                    column: column,
                    funcName: funcName
                )
            }

            // …and if we're notifiable, do so
            if notifiableErrorCodes.contains(statusCode) {
                NotificationCenter.default.post(name: .serverError, object: statusCode)
            }
        }
    }
}
