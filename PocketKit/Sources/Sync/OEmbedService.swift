// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

@MainActor
public class OEmbedService {
    public enum Error: Swift.Error {
        case anError
    }

    private let session: URLSessionProtocol

    public init(session: URLSessionProtocol) {
        self.session = session
    }

    public func fetch(request: OEmbedRequest) async throws -> OEmbed {
        let data = try await session.data(
            for: httpRequest(for: request),
            delegate: nil
        )

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(OEmbed.self, from: data.0)
    }

    private func httpRequest(for oEmbedRequest: OEmbedRequest) throws -> URLRequest {
        guard let id = oEmbedRequest.id else {
            throw Error.anError
        }

        var videoURLComponents = URLComponents(string: "https://vimeo.com")
        videoURLComponents?.path = "/\(id)"
        guard let videoURL = videoURLComponents?.url else {
            throw Error.anError
        }

        var components = URLComponents(string: "https://vimeo.com/api/oembed.json")
        components?.queryItems = [
            URLQueryItem(name: "url", value: videoURL.absoluteString),
            oEmbedRequest.width.flatMap { URLQueryItem(name: "width", value: "\($0)") }
        ].compactMap { $0 }
        guard let requestURL = components?.url else {
            throw Error.anError
        }

        return URLRequest(url: requestURL)
    }
}

@MainActor
public struct OEmbed: Decodable {
    public let html: String?
    public let width: Int?
    public let height: Int?
}

@MainActor
public struct OEmbedRequest {
    public let id: String?
    public let width: Int?

    public init(id: String?, width: Int?) {
        self.id = id
        self.width = width
    }
}
