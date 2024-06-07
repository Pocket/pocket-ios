// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Protocol to map url session, conforms to `Sendable` since so does `URLSession`
public protocol URLSessionProtocol: Sendable {
    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }
