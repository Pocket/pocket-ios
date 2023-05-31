// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import Foundation

extension ResponseCodeInterceptor.ResponseCodeError {
    static func withStatusCode(_ statusCode: Int) -> Self {
        ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(
            response: HTTPURLResponse(
                url: URL(string: "http://example.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            ),
            rawData: nil
        )
    }
}
