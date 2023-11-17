// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Apollo
import PocketGraph
import Combine
import SharedPocketKit

@testable import Sync

class PocketSearchServiceTests: XCTestCase {
    var apollo: MockApolloClient!
    var cancellables: [AnyCancellable] = []

    override func setUp() {
        super.setUp()
        apollo = MockApolloClient()
    }

    override func tearDown() {
        cancellables = []
        super.tearDown()
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

        await fulfillment(of: [searchExpectation], timeout: 10)

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

        wait(for: [searchExpectation], timeout: 10)

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

        wait(for: [searchExpectation], timeout: 10)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.none))
    }

    // MARK: Pagination
    func test_search_whenResponseIncludesMultiplePages_fetchesNextPage() async throws {
        apollo.setupSearchListResponseForPagination()
        let service = subject()

        try await service.search(for: "search-term", scope: .all)
        service.hasFinishedResults = false

        let firstPaginationExpectation = expectation(description: "first search page called")
        let secondPaginationExpectation = expectation(description: "second page called")
        let thirdPaginationExpectation = expectation(description: "third page called")
        var count = 0
        service.results.receive(on: DispatchQueue.main).sink { items in
            count += 1
            if count == 1 {
                XCTAssertEqual(items?.count, 2)
                firstPaginationExpectation.fulfill()
            } else if count == 2 {
                XCTAssertEqual(items?.count, 2)
                secondPaginationExpectation.fulfill()
            } else if count == 3 {
                XCTAssertEqual(items?.count, 1)
                thirdPaginationExpectation.fulfill()
            }
        }.store(in: &cancellables)

        XCTAssertEqual(self.apollo.fetchCalls(withQueryType: SearchSavedItemsQuery.self).count, 1)

        try await service.search(for: "search-term", scope: .all)

        XCTAssertEqual(self.apollo.fetchCalls(withQueryType: SearchSavedItemsQuery.self).count, 2)

        service.hasFinishedResults = false
        try await service.search(for: "search-term", scope: .all)
        XCTAssertEqual(self.apollo.fetchCalls(withQueryType: SearchSavedItemsQuery.self).count, 3)

        wait(for: [firstPaginationExpectation, secondPaginationExpectation, thirdPaginationExpectation], timeout: 10)
    }

    // MARK: Error
    func test_search_whenFetchFails_throwsError() async throws {
        apollo.stubFetch(ofQueryType: SearchSavedItemsQuery.self, toReturnError: TestError.anError)
        let service = subject()
        do {
            try await service.search(for: "search-term", scope: .all)
            XCTFail("Should have failed")
        } catch {
            XCTAssertEqual(error as? TestError, .anError)
        }
    }
}

// MARK: - Premium Search Experiment
extension PocketSearchServiceTests {
    func test_search_forTitle_fetchesSearchSavedItemsQueryWithCorrectFilter() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "search-term", scope: .premiumSearchExperimentTitle)

        wait(for: [searchExpectation], timeout: 10)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.onlyTitleAndURL, true)
    }

    func test_search_forTag_withNoPrefix_fetchesSearchSavedItemsQueryWithCorrectTerm() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "search term", scope: .premiumSearchExperimentTag)

        wait(for: [searchExpectation], timeout: 10)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "tag:\"search term\"")
        XCTAssertEqual(call?.query.filter.status, .init(.none))
    }

    func test_search_forTag_withPrefix_fetchesSearchSavedItemsQueryWithCorrectTerm() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "#search", scope: .premiumSearchExperimentTag)

        wait(for: [searchExpectation], timeout: 10)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "#search")
        XCTAssertEqual(call?.query.filter.status, .init(.none))
    }

    func test_search_forContent_fetchesSearchSavedItemsQueryWithTerm() async throws {
        apollo.setupSearchListResponse()
        let service = subject()
        let searchExpectation = expectation(description: "searchExpectation")

        service.results.dropFirst().first().receive(on: DispatchQueue.main).sink { _ in
            searchExpectation.fulfill()
        }.store(in: &cancellables)

        try await service.search(for: "search-term", scope: .premiumSearchExperimentContent)

        wait(for: [searchExpectation], timeout: 10)

        let call: MockApolloClient.FetchCall<SearchSavedItemsQuery>? = self.apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.term, "search-term")
        XCTAssertEqual(call?.query.filter.status, .init(.none))
    }
}

extension MockApolloClient {
    func setupSearchListResponse(fixtureName: String = "search-list") {
        stubFetch(toReturnFixture: Fixture.load(name: fixtureName), asResultType: SearchSavedItemsQuery.self)
    }

    func setupSearchListResponseForPagination(fixtureName: String = "search-list-page-1") {
        stubFetch { (query: SearchSavedItemsQuery, _, _, _, queue, completion) in
            let resultFixtureName: String
            switch query.pagination.after {
            case nil:
                resultFixtureName = "search-list-page-1"
            case .some(let cursor):
                switch cursor {
                case .none, .some(""):
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
