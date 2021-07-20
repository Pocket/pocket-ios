// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import PocketKit

class MockURLSession: URLSessionProtocol {
    struct DataCall {
        let request: URLRequest
    }

    typealias DataImpl = (URLRequest) throws -> (Data, URLResponse)

    private var dataImpl: DataImpl?

    var dataTaskCalls: [DataCall] = []

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard let impl = dataImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }
        
        dataTaskCalls.append(DataCall(request: request))
        return try impl(request)
    }

    func stubData(_ impl: @escaping DataImpl) {
        dataImpl = impl
    }
}
