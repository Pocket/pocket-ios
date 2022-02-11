import XCTest
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

    func perform(operation: FetchArchivePageOperation) {
        let expectCompletion = expectation(description: "Expect the operation to complete")
        operation.completionBlock = {
            expectCompletion.fulfill()
        }

        queue.addOperation(operation)
        wait(for: [expectCompletion], timeout: 1)
    }

    func test_theOperation_executesAQuery() {
        let operation = subject()
        perform(operation: operation)

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertNotNil(call)
        XCTAssertEqual(call?.query.token, "test-token")
        XCTAssertEqual(call?.query.savedItemsFilter?.isArchived, true)
        XCTAssertEqual(call?.query.pagination?.after, nil)
        XCTAssertEqual(call?.query.pagination?.first, 30)
    }

    func test_theOperation_whenQuerySucceeds_storesResultsInCoreData() throws {
        perform(operation: subject())

        let archivedItems = try space.fetchArchivedItems()
        XCTAssertEqual(archivedItems.count, 2)
        XCTAssertEqual(archivedItems[0].remoteID, "archived-saved-item-1")
        XCTAssertEqual(archivedItems[1].remoteID, "archived-saved-item-2")
    }

    func test_theOperation_whenCursorIsPresent_usesTheCursorForPagination() {
        perform(operation: subject(cursor: "cursor-1"))

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.pagination?.after, "cursor-1")
        XCTAssertEqual(call?.query.pagination?.first, 30)
    }

    func test_whenIsFavoriteIsPresent_filtersByIsFavorite() {
        perform(operation: subject(isFavorite: false))

        let call: MockApolloClient.FetchCall<UserByTokenQuery>? = apollo.fetchCall(at: 0)
        XCTAssertEqual(call?.query.savedItemsFilter?.isFavorite, false)
    }
}
