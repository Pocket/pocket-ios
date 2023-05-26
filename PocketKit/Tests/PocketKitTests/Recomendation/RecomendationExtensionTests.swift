// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import Sync
@testable import PocketKit

class RecomendationExtensionTests: XCTestCase {
    private var source: MockSource!
    private var space: Space!
    private var allowedCharset: CharacterSet!

    override func setUp() {
        super.setUp()
        source = MockSource()
        space = .testSpace()
        allowedCharset = NSCharacterSet.urlHostAllowed
        allowedCharset.remove(charactersIn: ":%")
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try space.clear()
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_whenOnlyItemIsPresent_rendersItemFirst() throws {
        let subject = subject()
        assertCachedImageURLContainsOriginalImageURL(imageURL: subject.bestImageURL!, originalUrl: URL(string: "https://top-image-url.jpeg")!)
        XCTAssertEqual(subject.bestTitle, "Item 1")
        XCTAssertEqual(subject.bestExcerpt, "Some item excerpt")
        XCTAssertEqual(subject.bestDomain, "example.com")
    }

    func test_whenCuratedInfoIsPresent_rendersCuratedInfoFirst() throws {
        let subject = subjectWithCuratedInfo()
        assertCuratedInfo(subject)
    }

    func test_whenSyndicatedInfoIsPresent_rendersSyndicatedIfNoCuratedInfo() throws {
        let subject = subjectWithSyndicated()
        assertCachedImageURLContainsOriginalImageURL(imageURL: subject.bestImageURL!, originalUrl: URL(string: "https://syndicated-image.jpeg")!)
        XCTAssertEqual(subject.bestTitle, "Syndicated Title")
        XCTAssertEqual(subject.bestExcerpt, "Syndicated excerpt")
        XCTAssertEqual(subject.bestDomain, "Syndicated publisher name")
    }

    func test_whenAllDataPresent_rendersCuratedInfo() throws {
        let subject = subjectWithAllFields()
        assertCuratedInfo(subject)
    }
}

/**
 Extension to build the subjects and data
 */
extension RecomendationExtensionTests {
    func buildSyndicatedArticle() -> SyndicatedArticle {
        return space.buildSyndicatedArticle(
            title: "Syndicated Title",
            imageURL: URL(string: "https://syndicated-image.jpeg"),
            excerpt: "Syndicated excerpt",
            publisherName: "Syndicated publisher name"
        )
    }

    func buildItem(syndicatedArticle: SyndicatedArticle? = nil) -> Item {
        return space.buildItem(
            topImageURL: URL(string: "https://top-image-url.jpeg"),
            excerpt: "Some item excerpt",
            syndicatedArticle: syndicatedArticle
        )
    }

    func subject(item: Item? = nil, syndicatedArticle: SyndicatedArticle? = nil, imageURL: URL? = nil, title: String? = nil, excerpt: String? = nil) -> Recommendation {
        let item = item ?? buildItem()
        item.syndicatedArticle = syndicatedArticle

        let recommendation = space.buildRecommendation(
            item: item,
            imageURL: imageURL,
            title: title,
            excerpt: excerpt
        )
        return recommendation
    }

    func subjectWithCuratedInfo() -> Recommendation {
        return subject(
            imageURL: URL(string: "https://curated-info-image.jpeg"),
            title: "A Curated Title",
            excerpt: "Some curated excerpt"
        )
    }

    func subjectWithSyndicated() -> Recommendation {
        return subject(
            syndicatedArticle: buildSyndicatedArticle()
        )
    }

    func subjectWithAllFields() -> Recommendation {
        return subject(
            syndicatedArticle: buildSyndicatedArticle(),
            imageURL: URL(string: "https://curated-info-image.jpeg"),
            title: "A Curated Title",
            excerpt: "Some curated excerpt"
        )
    }
}

/**
 Helper to add a few assertions that are re-used
 */
extension RecomendationExtensionTests {
    /**
     Helper function to assert that a cached image url contains the original image.
     This is because the recomendation helpers will encode the underlying image to a image cache url
     */
    func assertCachedImageURLContainsOriginalImageURL(imageURL: URL, originalUrl: URL) {
        let string = originalUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: allowedCharset)!
        XCTAssertNotNil(imageURL.absoluteString.range(of: string))
    }

    func assertCuratedInfo(_ subject: Recommendation) {
        assertCachedImageURLContainsOriginalImageURL(imageURL: subject.bestImageURL!, originalUrl: URL(string: "https://curated-info-image.jpeg")!)
        XCTAssertEqual(subject.bestTitle, "A Curated Title")
        XCTAssertEqual(subject.bestExcerpt, "Some curated excerpt")
    }
}
