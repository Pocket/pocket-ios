import XCTest
import Apollo
import PocketGraph
import Combine
import SharedPocketKit

@testable import Sync

class PocketSearchServiceTests: XCTestCase {
    var apollo: MockApolloClient!
    var cancellables: [AnyCancellable] = []

    override func setUpWithError() throws {
        apollo = MockApolloClient()
    }

    override func tearDownWithError() throws {
        cancellables = []
    }

    func subject(
        apollo: ApolloClientProtocol? = nil
    ) -> PocketSearchService {
        PocketSearchService(
            apollo: apollo ?? self.apollo
        )
    }

    func test_search_forSaves_fetchesSearchSavedItemsQueryWithTerm() async {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        await service.search(for: "search-term", scope: .saves)

        wait(for: [searchExpectation], timeout: 1)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.unread))
    }

    func test_search_forArchive_fetchesSearchSavedItemsQueryWithTerm() async {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        await service.search(for: "search-term", scope: .archive)

        wait(for: [searchExpectation], timeout: 1)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.archived))
    }

    func test_search_forAll_fetchesSearchSavedItemsQueryWithTerm() async {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        await service.search(for: "search-term", scope: .all)

        wait(for: [searchExpectation], timeout: 1)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.none))
    }
}

extension MockApolloClient {
    func setupSearchListResponse(fixtureName: String = "search-list") {
        stubFetch(toReturnFixture: Fixture.load(name: fixtureName), asResultType: SearchSavedItemsQuery.self)
    }
}
