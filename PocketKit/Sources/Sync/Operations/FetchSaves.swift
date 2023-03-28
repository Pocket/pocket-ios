import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit

class FetchSaves: SyncOperation {
    private let user: User
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    private let lastRefresh: LastRefresh

    init(
        user: User,
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>,
        lastRefresh: LastRefresh
    ) {
        self.user = user
        self.apollo = apollo
        self.space = space
        self.events = events
        self.lastRefresh = lastRefresh
        self.initialDownloadState = initialDownloadState
    }

    func execute() async -> SyncOperationResult {
        do {
            if lastRefresh.lastRefreshSaves != nil {
                guard let lastRefreshTime = lastRefresh.lastRefreshSaves, Date().timeIntervalSince1970 - Double(lastRefreshTime) > SyncConstants.Saves.timeMustPass else {
                    Log.info("Not refreshing saves from server, last refresh is not above tolerance of \(SyncConstants.Saves.timeMustPass) seconds")
                    // Future TODO: We should have a new result called too soon that the ui can act on.
                    // However many states may not come from a user, IE. Instant Sync, Persistent Tasks that never finished, Retries
                    return .success
                }
            }

            async let saves: Void = fetchSaves()
            async let tags: Void = fetchTags()
            _ = await [try saves, try tags]
            lastRefresh.refreshedSaves()
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

    private func fetchSaves() async throws {
        var pagination = PaginationSpec(maxItems: SyncConstants.Saves.firstLoadMaxCount, pageSize: SyncConstants.Saves.initalPageSize)
        var i = 1
        repeat {
            Log.breadcrumb(category: "sync.saves", level: .debug, message: "Loading page \(i)")
            let result = try await fetchPage(pagination)

            if case .started = initialDownloadState.value,
               let totalCount = result.data?.user?.savedItems?.totalCount,
               pagination.cursor == nil {
                initialDownloadState.send(.paginating(totalCount: min(totalCount, pagination.maxItems)))
            }

            try updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result, pageSize: SyncConstants.Saves.pageSize)
            Log.breadcrumb(category: "sync.saves", level: .debug, message: "Finsihed loading page \(i)")
            i = i + 1
        } while pagination.shouldFetchNextPage

        initialDownloadState.send(.completed)
    }

    private func fetchTags() async throws {
        var shouldFetchNextPage = true
        var pagination = PaginationInput(first: .null)

        var pageNumber = 1
        repeat {
            Log.breadcrumb(category: "sync.tags", level: .debug, message: "Loading page \(pageNumber)")
            let query = TagsQuery(pagination: .init(pagination))
            let result = try await apollo.fetch(query: query)
            try updateLocalTags(result)

            if let pageInfo = result.data?.user?.tags?.pageInfo {
                pagination.after = pageInfo.endCursor ?? .none
                shouldFetchNextPage = pageInfo.hasNextPage
            } else {
                shouldFetchNextPage = false
            }
            Log.breadcrumb(category: "sync.tags", level: .debug, message: "Finsihed loading page \(pageNumber)")
            pageNumber += 1
        } while shouldFetchNextPage
    }

    private func fetchPage(_ pagination: PaginationSpec) async throws -> GraphQLResult<FetchSavesQuery.Data> {
        let query = FetchSavesQuery(
            pagination: .some(PaginationInput(
                after: pagination.cursor ?? .none,
                first: .some(pagination.pageSize)
            )),
            savedItemsFilter: .none
        )

        if let updatedSince = lastRefresh.lastRefreshSaves {
            query.savedItemsFilter = .some(SavedItemsFilter(updatedSince: .some(updatedSince)))
        } else {
            query.savedItemsFilter = .some(SavedItemsFilter(status: .init(.unread)))
        }

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(result: GraphQLResult<FetchSavesQuery.Data>) throws {
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

            space.performAndWait {
                let item = (try? space.fetchSavedItem(byRemoteID: node.remoteID)) ?? SavedItem(context: space.backgroundContext, url: url, remoteID: node.remoteID)
                item.update(from: edge, with: space)

                if item.deletedAt != nil {
                    space.delete(item)
                }
            }
        }

        try space.save()
    }

    func updateLocalTags(_ result: GraphQLResult<TagsQuery.Data>) throws {
        result.data?.user?.tags?.edges?.forEach { edge in
            guard let node = edge?.node else { return }
            space.performAndWait {
                let tag = space.fetchOrCreateTag(byName: node.name)
                tag.update(remote: node.fragments.tagParts)
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

        func nextPage(result: GraphQLResult<FetchSavesQuery.Data>, pageSize: Int) -> PaginationSpec {
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
