import Foundation
import Apollo
import Combine
import PocketGraph

class FetchList: SyncOperation {
    private let token: String
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    private let maxItems: Int
    private let lastRefresh: LastRefresh

    init(
        token: String,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        maxItems: Int,
        lastRefresh: LastRefresh
    ) {
        self.token = token
        self.apollo = apollo
        self.space = space
        self.events = events
        self.maxItems = maxItems
        self.lastRefresh = lastRefresh
        self.initialDownloadState = initialDownloadState
    }

    func execute() async -> SyncOperationResult {
        do {
            try await fetchList()
            try await fetchTags()

            lastRefresh.refreshed()
            return .success
        } catch {
            switch error {
            case is URLSessionClient.URLSessionClientError:
                return .retry(error)
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    return .retry(error)
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
            let result = try await fetchPage(pagination)

            if case .started = initialDownloadState.value,
               let totalCount = result.data?.userByToken?.savedItems?.totalCount,
               pagination.cursor == nil {
                initialDownloadState.send(.paginating(totalCount: totalCount))
            }

            try await updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result)
        } while pagination.shouldFetchNextPage

        initialDownloadState.send(.completed)
    }

    private func fetchTags() async throws {
        var shouldFetchNextPage = true
        var pagination = PaginationInput()

        while shouldFetchNextPage {
            let query = TagsQuery(pagination: .init(pagination))
            let result = try await apollo.fetch(query: query)
            try await updateLocalTags(result)

            if let pageInfo = result.data?.user?.tags?.pageInfo {
                pagination.after = pageInfo.endCursor ?? .none
                shouldFetchNextPage = pageInfo.hasNextPage
            } else {
                shouldFetchNextPage = false
            }
        }
    }

    private func fetchPage(_ pagination: PaginationSpec) async throws -> GraphQLResult<FetchSavesQuery.Data> {
        let query = FetchSavesQuery(
            token: token,
            pagination: .some(PaginationInput(
                after: pagination.cursor ?? .none,
                first: .some(pagination.maxItems)
            )),
            savedItemsFilter: .none
        )

        if let updatedSince = lastRefresh.lastRefresh {
            query.savedItemsFilter = .some(SavedItemsFilter(updatedSince: .some(updatedSince)))
        } else {
            query.savedItemsFilter = .some(SavedItemsFilter(status: .init(.unread)))
        }

        return try await apollo.fetch(query: query)
    }

    @MainActor
    private func updateLocalStorage(result: GraphQLResult<FetchSavesQuery.Data>) throws {
        guard let edges = result.data?.userByToken?.savedItems?.edges else {
            return
        }

        for edge in edges {
            guard let edge = edge, let node = edge.node else {
                return
            }

            Crashlogger.breadcrumb(
                category: "sync",
                level: .info,
                message: "Updating/Inserting SavedItem with ID: \(node.remoteID)"
            )

            let item = try space.fetchOrCreateSavedItem(byRemoteID: node.remoteID)
            item.update(from: edge, with: space)

            if item.deletedAt != nil {
                space.delete(item)
            }
        }

        try space.save()
    }

    @MainActor
    func updateLocalTags(_ result: GraphQLResult<TagsQuery.Data>) throws {
        result.data?.user?.tags?.edges?.forEach { edge in
            guard let node = edge?.node else { return }
            let tag = space.fetchOrCreateTag(byName: node.name)
            tag.update(remote: node.fragments.tagParts)
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

        func nextPage(result: GraphQLResult<FetchSavesQuery.Data>) -> PaginationSpec {
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
