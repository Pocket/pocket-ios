import Foundation
import Apollo
import Combine


class FetchList: AsyncOperation {
    private let token: String
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: PassthroughSubject<SyncEvent, Never>
    private let maxItems: Int
    private let lastRefresh: LastRefresh

    init(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) {
        self.token = token
        self.apollo = apollo
        self.space = space
        self.events = events
        self.maxItems = maxItems
        self.lastRefresh = lastRefresh

        super.init()
    }

    override func main() {
        fetchPage(maxItems: maxItems)
    }

    private func fetchPage(maxItems: Int, after: String? = nil) {
        let query = UserByTokenQuery(token: token)

        if let after = after {
            query.pagination = PaginationInput(after: after)
        }

        if let updatedSince = lastRefresh.lastRefresh {
            query.savedItemsFilter = SavedItemsFilter(updatedSince: String(updatedSince))
        }

        _ = apollo.fetch(query: query) { [weak self] result in
            self?.handle(result: result, maxItems: maxItems)
        }
    }

    private func handle(
        result: Result<GraphQLResult<UserByTokenQuery.Data>, Error>,
        maxItems: Int
    ) {
        switch result {
        case .failure(let error):
            failOperation(error: error)
        case .success(let data):
            handle(data: data.data, maxItems: maxItems)
        }
    }

    private func handle(data: UserByTokenQuery.Data?, maxItems: Int) {
        guard let savedItems = data?.userByToken?.savedItems,
              let edges = savedItems.edges,
              let maybeLastItem = edges.last,
              let lastItem = maybeLastItem else {
                  // User's list is empty
                  succeedOperation()
                  return
        }

        do {
            try createOrUpdateItems(from: edges)
        } catch {
            // TODO: Add a test for the case where core data throws an error
            // would probably require mocking `Space`
            failOperation(error: error)
            return
        }

        if savedItems.pageInfo.hasNextPage, maxItems > edges.count {
            fetchPage(maxItems: maxItems - edges.count, after: lastItem.cursor)
        } else {
            succeedOperation()
        }
    }

    private func createOrUpdateItems(
        from edges: [UserByTokenQuery.Data.UserByToken.SavedItem.Edge?]
    ) throws {
        for edge in edges {
            guard let node = edge?.node else {
                continue
            }

            let item = try space.fetchOrCreateItem(byURLString: node.url)
            item.update(from: node)
        }

        try space.save()
    }

    private func failOperation(error: Error) {
        // TODO: listen for error events on Source and capture errors there
        Crashlogger.capture(error: error)
        events.send(.error(error))
        finishOperation()
    }

    private func succeedOperation() {
        lastRefresh.refreshed()
        finishOperation()
    }
}
