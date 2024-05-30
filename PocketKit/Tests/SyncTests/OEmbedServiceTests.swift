// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import Sync

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

        let service = await OEmbedService(session: session)
        let oEmbedRequest = await OEmbedRequest(
            id: "286898202",
            width: 335
        )

        let oEmbed = try await service.fetch(request: oEmbedRequest)
        let html = await oEmbed.html
        let width = await oEmbed.width
        let height = await oEmbed.height
        XCTAssertEqual(html, #"<iframe src="https://player.vimeo.com/video/286898202"></iframe>"#)
        XCTAssertEqual(width, 480)
        XCTAssertEqual(height, 360)

        XCTAssertEqual(
            session.dataTaskCalls[0].request.url!.absoluteString,
            "https://vimeo.com/api/oembed.json?url=https://vimeo.com/286898202&width=335"
        )
    }
}
