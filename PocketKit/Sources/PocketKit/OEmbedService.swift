import Foundation


class OEmbedService {
    enum Error: Swift.Error {
        case anError
    }

    private let session: URLSessionProtocol

    init(session: URLSessionProtocol) {
        self.session = session
    }

    func fetch(request: OEmbedRequest) async throws -> OEmbed {
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

struct OEmbed: Decodable {
    let html: String?
    let width: Int?
    let height: Int?
}

struct OEmbedRequest {
    let id: String?
    let width: Int?
}
