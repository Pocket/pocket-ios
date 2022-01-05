import XCTest

@testable import PocketKit


class OEmbedServiceTests: XCTestCase {
    func test_itFetchesOEmbedContentWithProperURL() async throws {
        let session = MockURLSession()
        session.stubData { request in
            let data = Fixture.data(name: "oembed")
            let response = URLResponse(
                url: request.url!,
                mimeType: "application/json"
            )

            return (data, response)
        }

        let service = OEmbedService(session: session)
        let oEmbedRequest = OEmbedRequest(
            id: "286898202",
            width: 335
        )

        let oEmbed = try await service.fetch(request: oEmbedRequest)

        XCTAssertEqual(oEmbed.html, #"<iframe src="https://player.vimeo.com/video/286898202"></iframe>"#)
        XCTAssertEqual(oEmbed.width, 480)
        XCTAssertEqual(oEmbed.height, 360)

        XCTAssertEqual(
            session.dataTaskCalls[0].request.url!.absoluteString,
            "https://vimeo.com/api/oembed.json?url=https://vimeo.com/286898202&width=335"
        )
    }
}

extension URLResponse {
    convenience init(
        url: URL = URL(string: "http://example.com")!,
        mimeType: String = "application/json"
    ) {
        self.init(url: url, mimeType: mimeType, expectedContentLength: 0, textEncodingName: nil)
    }
}
