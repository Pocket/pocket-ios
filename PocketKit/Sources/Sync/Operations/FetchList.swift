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
        Task {
            do {
                try await fetchList()

                lastRefresh.refreshed()
                finishOperation()
            } catch {
                Crashlogger.capture(error: error)
                events.send(.error(error))
                finishOperation()
            }
        }
    }

    private func fetchList() async throws {
        var pagination = PaginationSpec(maxItems: maxItems)

        repeat {
            let result = try await fetchPage(cursor: pagination.cursor)
            try updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result)
        } while pagination.shouldFetchNextPage
    }

    private func fetchPage(cursor: String?) async throws -> GraphQLResult<UserByTokenQuery.Data> {
        let query = UserByTokenQuery(token: token)

        if let after = cursor {
            query.pagination = PaginationInput(after: after, first: 30)
        }

        if let updatedSince = lastRefresh.lastRefresh {
            query.savedItemsFilter = SavedItemsFilter(updatedSince: updatedSince)
        } else {
            query.savedItemsFilter = SavedItemsFilter(status: .unread)
        }

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(result: GraphQLResult<UserByTokenQuery.Data>) throws {
        guard let edges = result.data?.userByToken?.savedItems?.edges else {
            return
        }

        try space.context.performAndWait {
            for edge in edges {
                guard let node = edge?.node else {
                    continue
                }

                let item = try space.fetchOrCreateItem(byItemID: node.itemId)
                item.update(from: node)

                if item.deletedAt != nil, item.isArchived {
                    space.delete(item)
                }
            }

            try space.save()
        }
    }

    struct PaginationSpec {
        let cursor: String?
        let shouldFetchNextPage: Bool
        let maxItems: Int

        init(maxItems: Int) {
            self.init(cursor: nil, shouldFetchNextPage: false, maxItems: maxItems)
        }

        private init(cursor: String?, shouldFetchNextPage: Bool, maxItems: Int) {
            self.cursor = cursor
            self.shouldFetchNextPage = shouldFetchNextPage
            self.maxItems = maxItems
        }

        func nextPage(result: GraphQLResult<UserByTokenQuery.Data>) -> PaginationSpec {
            guard let savedItems = result.data?.userByToken?.savedItems,
                  let itemCount = savedItems.edges?.count,
                  let endCursor = savedItems.pageInfo.endCursor else {
                      return PaginationSpec(cursor: nil, shouldFetchNextPage: false, maxItems: maxItems)
                  }

            return PaginationSpec(
                cursor: endCursor,
                shouldFetchNextPage: savedItems.pageInfo.hasNextPage && itemCount < maxItems,
                maxItems: maxItems - itemCount
            )
        }
    }
}
