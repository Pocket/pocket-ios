import Foundation
import Apollo
import Combine


class FetchList: AsyncOperation {
    private let token: String
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: PassthroughSubject<SyncEvent, Never>
    private let maxItems: Int

    init(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: PassthroughSubject<SyncEvent, Never>,
        maxItems: Int
    ) {
        self.token = token
        self.apollo = apollo
        self.space = space
        self.events = events
        self.maxItems = maxItems

        super.init()
    }

    override func main() {
        fetchPage(maxItems: maxItems)
    }

    private func fetchPage(maxItems: Int, after: String? = nil) {
        let query: UserByTokenQuery

        if let after = after {
            let pagination = PaginationInput(after: after)
            query = UserByTokenQuery(token: token, pagination: pagination)
        } else {
            query = UserByTokenQuery(token: token)
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
                  // We got a successful response from the server but
                  // there was no meaningful data in the response
                  // You could make the case that we should error here,
                  // but at the moment we just consider the operation complete
                  finishOperation()
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
            finishOperation()
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
}
