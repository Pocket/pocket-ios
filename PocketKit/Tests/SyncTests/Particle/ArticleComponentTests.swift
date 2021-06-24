// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync


class ArticleComponentTests: XCTestCase {
    func test_decode_decodesEachTypeOfTextComponent() {
        let article: Article = Fixture.decode(name: "particle/text-components")

        XCTAssertEqual(
            article.content[0],
            .bodyText(BodyText(text: TextContent(text: "this is a BodyText component")))
        )

        XCTAssertEqual(
            article.content[1],
            .quote(Quote(text: TextContent(text: "this is a Quote component")))
        )

        XCTAssertEqual(
            article.content[2],
            .pre(Pre(text: TextContent(text: "this is a Pre component")))
        )

        XCTAssertEqual(
            article.content[3],
            .title(Title(text: TextContent(text: "this is a Title component")))
        )

        XCTAssertEqual(
            article.content[4],
            .byline(Byline(text: TextContent(text: "this is a Byline component")))
        )

        XCTAssertEqual(
            article.content[5],
            .message(Message(text: TextContent(text: "this is a Message component")))
        )

        XCTAssertEqual(
            article.content[6],
            .copyright(Copyright(text: TextContent(text: "this is a Copyright component")))
        )

        XCTAssertEqual(
            article.content[7],
            .publisherMessage(
                PublisherMessage(
                    pkta: "publisher-message-feature",
                    text: TextContent(text: "this is a PublisherMessage component")
                )
            )
        )

        XCTAssertEqual(
            article.content[8],
            .header(
                Header(
                    level: 3,
                    text: TextContent(text: "this is a Header component")
                )
            )
        )
    }

    func test_decode_decodesAnImageComponent() {
        let article: Article = Fixture.decode(name: "particle/image")

        XCTAssertEqual(
            article.content[0],
            .image(ImageComponent(id: "1"))
        )
    }

    func test_decode_whenTypeIsUnrecognized_createsUnsupportedComponent() {
        let article: Article = Fixture.decode(name: "particle/unsupported-article-component")

        XCTAssertEqual(
            article.content[0],
            .unsupported("unrecognizable-component")
        )
    }
}
