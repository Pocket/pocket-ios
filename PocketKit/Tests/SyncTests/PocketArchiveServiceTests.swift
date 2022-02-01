import XCTest
@testable import Sync


class PocketArchiveServiceTests: XCTestCase {
    var apollo: MockApolloClient!

    override func setUpWithError() throws {
        apollo = MockApolloClient()
    }

    func subject(apollo: MockApolloClient? = nil) -> PocketArchiveService {
        PocketArchiveService(apollo: apollo ?? self.apollo)
    }

    func test_fetch_usesTheCorrectQuery() async throws {
        apollo.stubFetch(toReturnFixturedNamed: "archived-items", asResultType: UserByTokenQuery.self)
        
        _ = try await subject().fetch(accessToken: "the-access-token", isFavorite: false)
        
        let unfavoritedCall: MockApolloClient.FetchCall<UserByTokenQuery> = apollo.fetchCall(at: 0)
        XCTAssertEqual(unfavoritedCall.query.savedItemsFilter?.isArchived, true)
        XCTAssertEqual(unfavoritedCall.query.savedItemsFilter?.isFavorite, false)
        
        _ = try await subject().fetch(accessToken: "the-access-token", isFavorite: true)
        
        let favoritedCall: MockApolloClient.FetchCall<UserByTokenQuery> = apollo.fetchCall(at: 1)
        XCTAssertEqual(favoritedCall.query.savedItemsFilter?.isArchived, true)
        XCTAssertEqual(favoritedCall.query.savedItemsFilter?.isFavorite, true)
    }

    func test_fetch_returnsMappedArchivedItems() async throws {
        apollo.stubFetch(toReturnFixturedNamed: "archived-items", asResultType: UserByTokenQuery.self)
        let fetchedItems = try await subject().fetch(accessToken: "the-access-token", isFavorite: false)

        XCTAssertEqual(fetchedItems.count, 2)

        do {
            let archivedItem = fetchedItems[0]
            XCTAssertEqual(archivedItem.remoteID, "archived-saved-item-1")
            XCTAssertEqual(archivedItem.url, URL(string: "http://example.com/items/archived-item-1"))
            XCTAssertEqual(archivedItem.createdAt, Date(timeIntervalSince1970: 0))
            XCTAssertEqual(archivedItem.deletedAt, nil)
            XCTAssertEqual(archivedItem.isArchived, true)
            XCTAssertEqual(archivedItem.isFavorite, false)

            let item = archivedItem.item!
            XCTAssertEqual(item.id, "archived-item-1")
            XCTAssertEqual(item.title, "Archived Item 1")
            XCTAssertEqual(item.givenURL, URL(string: "http://example.com/items/archived-item-1"))
            XCTAssertEqual(item.resolvedURL, URL(string: "http://example.com/items/archived-item-1"))
            XCTAssertEqual(item.topImageURL, URL(string: "https://example.com/archived-item-1/top-image.jpg"))
            XCTAssertEqual(item.domain, "wired.com")
            XCTAssertEqual(item.language, "en")
            XCTAssertEqual(item.timeToRead, 6)
            XCTAssertEqual(item.excerpt, "Risus Aenean Ultricies Nullam Vehicula")
            XCTAssertEqual(item.datePublished, Date(timeIntervalSince1970: 978350461))

            XCTAssertEqual(
                item.article?.components[0],
                ArticleComponent.text(TextComponent(content: "**Commodo Consectetur** _Dapibus_"))
            )

            let author = item.authors?[0]
            XCTAssertEqual(author?.id, "archived-author-1")
            XCTAssertEqual(author?.name, "Socrates")
            XCTAssertEqual(author?.url, URL(string: "https://example.com/authors/socrates"))

            let domainMetadata = item.domainMetadata
            XCTAssertEqual(domainMetadata?.name, "WIRED")
            XCTAssertEqual(domainMetadata?.logo, URL(string: "http://example.com/item-1/domain-logo.jpg"))

            let image = item.images?[0]
            XCTAssertEqual(image?.imageID, 1)
            XCTAssertEqual(image?.height, 1)
            XCTAssertEqual(image?.width, 2)
            XCTAssertEqual(image?.src, URL(string: "http://example.com/item-1/image-1.jpg"))
        }

        do {
            let archivedItem = fetchedItems[1]
            XCTAssertEqual(archivedItem.remoteID, "archived-saved-item-2")
        }
    }
}
