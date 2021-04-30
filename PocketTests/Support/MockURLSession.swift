// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import Pocket

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    var resumeCalls = 0

    func resume() {
        resumeCalls += 1
    }
}

class MockURLSession: URLSessionProtocol {
    struct DataTaskCall {
        let request: URLRequest
    }

    typealias DataTaskImpl = (URLRequest, (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol

    private var dataTaskWithCompletionImpl: DataTaskImpl?

    var dataTaskCalls: [DataTaskCall] = []

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        guard let impl = dataTaskWithCompletionImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        dataTaskCalls.append(DataTaskCall(request: request))
        return impl(request, completionHandler)
    }

    func stubDataTaskWithCompletion(impl: @escaping DataTaskImpl) {
        dataTaskWithCompletionImpl = impl
    }
}
