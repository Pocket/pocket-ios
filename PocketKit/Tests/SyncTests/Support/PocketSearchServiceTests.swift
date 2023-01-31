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

    func test_search_forSaves_fetchesSearchSavedItemsQueryWithTerm() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "search-term", scope: .saves)

        wait(for: [searchExpectation], timeout: 1)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.unread))
    }

    func test_search_forArchive_fetchesSearchSavedItemsQueryWithTerm() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "search-term", scope: .archive)

        wait(for: [searchExpectation], timeout: 1)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.archived))
    }

    func test_search_forAll_fetchesSearchSavedItemsQueryWithTerm() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "search-term", scope: .all)

        wait(for: [searchExpectation], timeout: 1)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.none))
    }

    // MARK: Pagination
    func test_search_whenResponseIncludesMultiplePages_fetchesNextPage() async throws {
        apollo.setupSearchListResponseForPagination()
        let service = subject()

        try await service.search(for: "search-term", scope: .all)

        XCTAssertEqual(self.apollo.fetchCalls(withQueryType: SearchSavedItemsQuery.self).count, 3)
    }
}

extension MockApolloClient {
    func setupSearchListResponse(fixtureName: String = "search-list") {
        stubFetch(toReturnFixture: Fixture.load(name: fixtureName), asResultType: SearchSavedItemsQuery.self)
    }

    func setupSearchListResponseForPagination(fixtureName: String = "search-list-page-1") {
        stubFetch { (query: SearchSavedItemsQuery, _, _, queue, completion) in
            let resultFixtureName: String
            switch query.pagination.after {
            case nil:
                resultFixtureName = "search-list-page-1"
            case .some(let cursor):
                switch cursor {
                case .none:
                    resultFixtureName = "search-list-page-1"
                case .some(let cursor):
                    switch cursor {
                    case "cursor-2":
                        resultFixtureName = "search-list-page-2"
                    case "cursor-4":
                        resultFixtureName = "search-list-page-3"
                    default:
                        fatalError("Unexpected pagination cursor: \(cursor)")
                    }
                case .null:
                    fatalError("Unexpected pagination cursor: \(cursor)")
                }
            }

            queue.async {
                let fixture = Fixture.load(name: resultFixtureName)
                let graphQLResult = fixture.asGraphQLResult(from: query)

                completion?(.success(graphQLResult))
            }

            return MockCancellable()
        }
    }
}
