import XCTest
import Combine
import Apollo

@testable import Sync


class APISlateServiceTests: XCTestCase {
    var apollo: MockApolloClient!

    override func setUpWithError() throws {
        apollo = MockApolloClient()
    }

    func subject(apollo: MockApolloClient? = nil) -> APISlateService {
        APISlateService(apollo: apollo ?? self.apollo)
    }

    func test_fetchSlateLineup_returnsSlateLineup() async throws {
        apollo.stubFetch(toReturnFixturedNamed: "slates", asResultType: GetSlateLineupQuery.self)

        let lineup = try await subject().fetchSlateLineup("slate-lineup-1")
        XCTAssertNotNil(lineup)
        XCTAssertEqual(lineup!.id, "slate-lineup-1")
        XCTAssertEqual(lineup!.requestID, "slate-lineup-1-request")
        XCTAssertEqual(lineup!.experimentID, "slate-lineup-1-experiment")

        XCTAssertEqual(lineup?.slates.count, 2)

        do {
            let slate = lineup!.slates[0]
            XCTAssertEqual(slate.id, "slate-1")
            XCTAssertEqual(slate.requestID, "slate-1-request")
            XCTAssertEqual(slate.experimentID, "slate-1-experiment")
            XCTAssertEqual(slate.name, "Slate 1")
            XCTAssertEqual(slate.description, "The description of slate 1")
            XCTAssertEqual(slate.recommendations.count, 2)

            let recommendations = slate.recommendations

            do {
                let recommendation = recommendations[0]
                XCTAssertEqual(recommendation.id, "slate-1-rec-1")
            }

            do {
                let recommendation = recommendations[1]
                XCTAssertEqual(recommendation.id, "slate-1-rec-2")
            }
        }

        do {
            let slate = lineup!.slates[1]
            XCTAssertEqual(slate.id, "slate-2")
            XCTAssertEqual(slate.requestID, "slate-2-request")
            XCTAssertEqual(slate.experimentID, "slate-2-experiment")
            XCTAssertEqual(slate.name, "Slate 2")
            XCTAssertEqual(slate.description, "The description of slate 2")
            XCTAssertEqual(slate.recommendations.count, 1)

            let recommendation = slate.recommendations[0]
            XCTAssertEqual(recommendation.id, "slate-2-rec-1")

            let item = recommendation.item
            XCTAssertEqual(item.id, "item-3")
            XCTAssertEqual(item.givenURL, URL(string: "https://given.example.com/rec-1")!)
            XCTAssertEqual(item.resolvedURL, URL(string: "https://resolved.example.com/rec-1")!)
            XCTAssertEqual(item.title, "Slate 2, Recommendation 1")
            XCTAssertEqual(item.language, "en")
            XCTAssertEqual(item.topImageURL, URL(string: "http://example.com/slate-2-rec-1/top-image.png"))
            XCTAssertEqual(item.timeToRead, 3)
            XCTAssertEqual(item.excerpt, "Cursus Aenean Elit")
            XCTAssertEqual(item.domain, "slate-2-rec-1.example.com")
            XCTAssertEqual(item.datePublished, Date(timeIntervalSinceReferenceDate: 631195261))

            let image = item.images?[0]
            XCTAssertEqual(image?.height, 0)
            XCTAssertEqual(image?.width, 0)
            XCTAssertEqual(image?.src, URL(string: "http://example.com/slate-2-rec-1/image-1.png")!)
            XCTAssertEqual(image?.imageID, 1)

            let domain = item.domainMetadata
            XCTAssertNotNil(domain)
            XCTAssertEqual(domain?.name, "Lifehacker")
            XCTAssertEqual(domain?.logo, URL(string: "https://slate-2-rec-1.example.com/logo.png"))

            let author = item.authors?[0]
            XCTAssertEqual(author?.id, "eb-white")
            XCTAssertEqual(author?.name, "E.B. White")
            XCTAssertEqual(author?.url, URL(string: "http://example.com/authors/eb-white")!)

            switch item.article?.components[0] {
            case .blockquote(let blockquote):
                XCTAssertEqual(blockquote.content, "Pellentesque Ridiculus Porta")
            case .none:
                XCTFail("Expected blockquote component, got nil")
            case .some(let component):
                XCTFail("Expected blockquote component, got \(component)")
            }
        }
    }

    func test_fetchSlate_returnsSlateDetails() async throws {
        apollo.stubFetch(toReturnFixturedNamed: "slate-detail", asResultType: GetSlateQuery.self)

        let slate = try await subject().fetchSlate("the-slate-id")

        XCTAssertEqual(slate?.id, "slate-1")
        XCTAssertEqual(slate?.name, "Slate 1")
        XCTAssertEqual(slate?.description, "The description of slate 1")
        XCTAssertEqual(slate?.recommendations.count, 3)

        let recommendations = slate?.recommendations

        do {
            let recommendation = recommendations?[0]
            XCTAssertEqual(recommendation?.id, "1")
        }

        do {
            let recommendation = recommendations?[1]
            XCTAssertEqual(recommendation?.id, "2")
        }

        do {
            let recommendation = recommendations?[2]
            XCTAssertEqual(recommendation?.id, "3")
        }
    }
}
