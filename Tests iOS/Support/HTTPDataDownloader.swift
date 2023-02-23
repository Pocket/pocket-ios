// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

let validStatus = 200...299
protocol HTTPDataDownloader {
    func httpData(from: URL, method: String) async throws -> Data
}

enum HTTPDataDownloaderError: Error {
    // Throw when a network error occurs
    case networkError
}

extension URLSession: HTTPDataDownloader {
    func httpData(from url: URL, method: String = "GET") async throws -> Data {
        var request = URLRequest(
                    url: url,
                    cachePolicy: .reloadIgnoringLocalCacheData
                )
        request.httpMethod = method
        guard let (data, response) = try await self.data(for: request) as? (Data, HTTPURLResponse),
              validStatus.contains(response.statusCode) else {
            throw HTTPDataDownloaderError.networkError
        }
        return data
    }
}
