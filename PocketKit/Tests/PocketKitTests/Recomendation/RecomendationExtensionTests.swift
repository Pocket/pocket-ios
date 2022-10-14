import XCTest
import Sync

@testable import Sync
@testable import PocketKit

class RecomendationExtensionTests: XCTestCase {
    private var source: MockSource!
    private var space: Space!

    override func setUp() {
        source = MockSource()
        space = .testSpace()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try space.clear()
    }

// MARK: - Builder Helpers

    func buildItem(syndicatedArticle: SyndicatedArticle? = nil) -> Item {
        return space.buildItem(
            topImageURL: URL(string: "https://top-image-url.jpeg"),
            excerpt: "Some item excerpt",
            syndicatedArticle: syndicatedArticle
        )
    }

    func subjectWithItem() -> Recommendation {
        let recommendation = space.buildRecommendation(item: buildItem())
        return recommendation
    }

    func subjectWithCuratedInfo() -> Recommendation {
        let recommendation = space.buildRecommendation(
            item: buildItem(),
            imageURL: URL(string: "https://curated-info-image.jpeg"),
            title: "A Curated Title",
            excerpt: "Some curated excerpt"
        )
        return recommendation
    }

    func buildSyndicatedArticle() -> SyndicatedArticle {
        return space.buildSyndicatedArticle(
            title: "Syndicated Title",
            imageURL: URL(string: "https://syndicated-image.jpeg"),
            excerpt: "Syndicated excerpt",
            publisherName: "Syndicated publisher name"
        )
    }

    func subjectWithSyndicated() -> Recommendation {
        let recommendation = space.buildRecommendation(
            item: buildItem(
                syndicatedArticle: buildSyndicatedArticle()
            )
        )
        return recommendation
    }

    func subjectWithAllFields() -> Recommendation {
        let recommendation = space.buildRecommendation(
            item: buildItem(
                syndicatedArticle: buildSyndicatedArticle()
            ),
            imageURL: URL(string: "https://curated-info-image.jpeg"),
            title: "A Curated Title",
            excerpt: "Some curated excerpt"

        )
        return recommendation
    }

// MARK: - Assertion Helpers

    /**
     Helper function to assert that a cached image url contains the original image.
     This is because the recomendation helpers will encode the underlying image to a image cache url
     */
    func assertCachedImageURLContainsOriginalImageURL(imageURL: URL, originalUrl: URL) {
        XCTAssertNotNil(imageURL.absoluteString.range(of: originalUrl.absoluteString))
    }

    func curatedInfoAssertions(subject: Recommendation) {
        assertCachedImageURLContainsOriginalImageURL(imageURL: subject.bestImageURL!, originalUrl: URL(string: "https://curated-info-image.jpeg")!)
        XCTAssertEqual(subject.bestTitle, "A Curated Title")
        XCTAssertEqual(subject.bestExcerpt, "Some curated excerpt")
    }

// MARK: - Tests

    func test_whenOnlyItemIsPresent_rendersItemFirst() throws {
        let subject = subjectWithItem()
        assertCachedImageURLContainsOriginalImageURL(imageURL: subject.bestImageURL!, originalUrl: URL(string: "https://top-image-url.jpeg")!)
        XCTAssertEqual(subject.bestTitle, "Item 1")
        XCTAssertEqual(subject.bestExcerpt, "Some item excerpt")
        XCTAssertEqual(subject.bestDomain, "example.com")
    }

    func test_whenCuratedInfoIsPresent_rendersCuratedInfoFirst() throws {
        let subject = subjectWithCuratedInfo()
        curatedInfoAssertions(subject: subject)
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
        curatedInfoAssertions(subject: subject)
    }
}
