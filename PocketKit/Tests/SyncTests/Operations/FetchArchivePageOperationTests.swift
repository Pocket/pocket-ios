import XCTest
import Apollo
import Foundation
@testable import Sync


class FetchArchivePageOperationTests: XCTestCase {
    var apollo: MockApolloClient!
    var space: Space!
    var queue: OperationQueue!

    override func setUpWithError() throws {
        apollo = MockApolloClient()
        apollo.stubFetch(
            toReturnFixturedNamed: "archived-items",
            asResultType: UserByTokenQuery.self
        )

        space = Space(container: .testContainer)
        queue = OperationQueue()
    }

    func subject(
        apollo: MockApolloClient? = nil,
        space: Space? = nil,
        accessToken: String = "test-token",
        cursor: String? = nil,
        isFavorite: Bool? = nil
    ) -> FetchArchivePageOperation {
        FetchArchivePageOperation(
            apollo: apollo ?? self.apollo,
            space: space ?? self.space,
            accessToken: accessToken,
            cursor: cursor,
            isFavorite: isFavorite
        )
    }

    func test_theOperation_executesAQuery() async {
        let service = subject()
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.query.token, "test-token")
        XCTAssertEqual(call?.query.savedItemsFilter?.isArchived, true)
        XCTAssertEqual(call?.query.pagination?.after, nil)
        XCTAssertEqual(call?.query.pagination?.first, 30)
    }

    func test_theOperation_whenQuerySucceeds_storesResultsInCoreData() async throws {
        let service = subject()
        _ = await service.execute()

        let archivedItems = try space.fetchArchivedItems()
        XCTAssertEqual(archivedItems.count, 2)
        XCTAssertEqual(archivedItems[0].remoteID, "archived-saved-item-1")
        XCTAssertEqual(archivedItems[1].remoteID, "archived-saved-item-2")
    }

    func test_theOperation_whenCursorIsPresent_usesTheCursorForPagination() async {
        let service = subject(cursor: "cursor-1")
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.pagination?.after, "cursor-1")
        XCTAssertEqual(call?.query.pagination?.first, 30)
    }

    func test_whenIsFavoriteIsPresent_filtersByIsFavorite() async {
        let service = subject(isFavorite: false)
        _ = await service.execute()

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.savedItemsFilter?.isFavorite, false)
    }

    func test_execute_whenClientSideNetworkFails_retries() async {
        let initialError = URLSessionClient.URLSessionClientError.networkError(
            data: Data(),
            response: nil,
            underlying: TestError.anError
        )

        apollo.stubFetch(ofQueryType: UserByTokenQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }

    func test_execute_whenResponseIs5XX_retries() async {
        let initialError = ResponseCodeInterceptor.ResponseCodeError.withStatusCode(500)
        apollo.stubFetch(ofQueryType: UserByTokenQuery.self, toReturnError: initialError)

        let service = subject()
        let result = await service.execute()

        guard case .retry = result else {
            XCTFail("Expected retry result but got \(result)")
            return
        }
    }
}
