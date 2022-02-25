import Foundation
import Apollo
import Combine


class FetchList: SyncOperation {
    private let token: String
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let maxItems: Int
    private let lastRefresh: LastRefresh

    init(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) {
        self.token = token
        self.apollo = apollo
        self.space = space
        self.events = events
        self.maxItems = maxItems
        self.lastRefresh = lastRefresh
    }

    func execute() async -> SyncOperationResult {
        do {
            try await fetchList()

            lastRefresh.refreshed()
            return .success
        } catch {
            switch error {
            case is URLSessionClient.URLSessionClientError:
                return .retry
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    return .retry
                default:
                    return .failure(error)
                }
            default:
                Crashlogger.capture(error: error)
                events.send(.error(error))
                return .failure(error)
            }
        }
    }

    private func fetchList() async throws {
        var pagination = PaginationSpec(maxItems: maxItems)

        repeat {
            let result = try await fetchPage(cursor: pagination.cursor)
            try await updateLocalStorage(result: result)
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

    @MainActor
    private func updateLocalStorage(result: GraphQLResult<UserByTokenQuery.Data>) throws {
        guard let edges = result.data?.userByToken?.savedItems?.edges else {
            return
        }

        for edge in edges {
            guard let edge = edge, let node = edge.node else {
                return
            }

            let item = try space.fetchOrCreateSavedItem(byRemoteID: node.remoteId)
            item.update(from: edge)

            if item.deletedAt != nil {
                space.delete(item)
            }
        }

        try space.save()
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
