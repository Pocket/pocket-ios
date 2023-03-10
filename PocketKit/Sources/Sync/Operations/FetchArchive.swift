import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit

class FetchArchive: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    private let lastRefresh: LastRefresh

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) {
        self.apollo = apollo
        self.space = space
        self.events = events
        self.lastRefresh = lastRefresh
        self.initialDownloadState = initialDownloadState
    }

    func execute() async -> SyncOperationResult {
        do {
            try await fetchArchive()

            lastRefresh.refreshedArchive()
            return .success
        } catch {
            switch error {
            case is URLSessionClient.URLSessionClientError:
                Log.breadcrumb(
                    category: "sync",
                    level: .error,
                    message: "URLSessionClient.URLSessionClientError with Error: \(error.localizedDescription)"
                )
                return .retry(error)
            case ResponseCodeInterceptor.ResponseCodeError.invalidResponseCode(let response, _):
                switch response?.statusCode {
                case .some((500...)):
                    Log.breadcrumb(
                        category: "sync",
                        level: .error,
                        message: "ResponseCodeInterceptor.ResponseCodeError with Error: \(error.localizedDescription) and status code \(String(describing: response?.statusCode))"
                    )
                    return .retry(error)
                default:
                    return .failure(error)
                }
            default:
                Log.capture(error: error)
                events.send(.error(error))
                return .failure(error)
            }
        }
    }

    private func fetchArchive() async throws {
        var pagination = PaginationSpec(maxItems: SyncConstants.Archive.firstLoadMaxCount, pageSize: SyncConstants.Archive.initalPageSize)

        repeat {
            let result = try await fetchPage(pagination)

            if case .started = initialDownloadState.value,
               let totalCount = result.data?.user?.savedItems?.totalCount,
               pagination.cursor == nil {
                initialDownloadState.send(.paginating(totalCount: totalCount > pagination.maxItems ? pagination.maxItems : totalCount))
            }

            try await updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result, pageSize: SyncConstants.Archive.pageSize)
        } while pagination.shouldFetchNextPage

        initialDownloadState.send(.completed)
    }

    private func fetchPage(_ pagination: PaginationSpec) async throws -> GraphQLResult<FetchArchiveQuery.Data> {
        let query = FetchArchiveQuery(
            pagination: .some(PaginationInput(
                after: pagination.cursor ?? .none,
                first: .some(pagination.pageSize)
            )),
            filter: .none,
            sort: .some(SavedItemsSort(sortBy: .init(.archivedAt), sortOrder: .init(.desc)))
        )

        if let updatedSince = lastRefresh.lastRefreshArchive {
            query.filter = .some(SavedItemsFilter(updatedSince: .some(updatedSince)))
        } else {
            query.filter = .some(SavedItemsFilter(statuses: .some([.init(.archived)])))
        }

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(result: GraphQLResult<FetchArchiveQuery.Data>) throws {
        guard let edges = result.data?.user?.savedItems?.edges else {
            return
        }

        for edge in edges {
            guard let edge = edge, let node = edge.node, let url = URL(string: node.url) else {
                return
            }

            Log.breadcrumb(
                category: "sync",
                level: .info,
                message: "Updating/Inserting SavedItem with ID: \(node.remoteID)"
            )

            let item = (try? space.fetchSavedItem(byRemoteID: node.remoteID)) ?? SavedItem(context: space.context, url: url, remoteID: node.remoteID)

            item.update(from: node.fragments.savedItemSummary, with: space)

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
        let pageSize: Int

        init(maxItems: Int, pageSize: Int) {
            self.init(cursor: nil, shouldFetchNextPage: false, maxItems: maxItems, pageSize: pageSize)
        }

        private init(cursor: String?, shouldFetchNextPage: Bool, maxItems: Int, pageSize: Int) {
            self.cursor = cursor
            self.shouldFetchNextPage = shouldFetchNextPage
            self.maxItems = maxItems
            self.pageSize = pageSize
        }

        func nextPage(result: GraphQLResult<FetchArchiveQuery.Data>, pageSize: Int) -> PaginationSpec {
            guard let savedItems = result.data?.user?.savedItems,
                  let itemCount = savedItems.edges?.count,
                  let endCursor = savedItems.pageInfo.endCursor else {
                      return PaginationSpec(cursor: nil, shouldFetchNextPage: false, maxItems: maxItems, pageSize: pageSize)
                  }

            return PaginationSpec(
                cursor: endCursor,
                shouldFetchNextPage: savedItems.pageInfo.hasNextPage && itemCount < maxItems,
                maxItems: maxItems - itemCount,
                pageSize: pageSize
            )
        }
    }
}
