// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit
import CoreData

class FetchArchive: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    private let lastRefresh: LastRefresh
    // Force unwrapping, because the entry point, execute, will ensure that this exists with a guard
    private var persistentTask: PersistentSyncTask!

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

    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult {
        guard let persistentTask = space.backgroundObject(with: syncTaskId) as? PersistentSyncTask else {
            return .retry(NoPersistentTaskOperationError())
        }
        self.persistentTask = persistentTask

        do {
            if lastRefresh.lastRefreshArchive != nil {
                guard let lastRefreshTime = lastRefresh.lastRefreshArchive, Date().timeIntervalSince1970 - Double(lastRefreshTime) > SyncConstants.Archive.timeMustPass else {
                    Log.info("Not refreshing archives from server, last refresh is not above tolerance of \(SyncConstants.Archive.timeMustPass) seconds")
                    // Future TODO: We should have a new result called too soon that the ui can act on.
                    // However many states may not come from a user, IE. Instant Sync, Persistent Tasks that never finished, Retries
                    return .success
                }
            }

            if lastRefresh.lastRefreshArchive == nil {
                initialDownloadState.send(.started)
            }

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
        if let cursor = persistentTask.currentCursor {
            pagination = PaginationSpec(maxItems: SyncConstants.Archive.firstLoadMaxCount, pageSize: SyncConstants.Archive.initalPageSize, cursor: cursor)
        }

        var pageNumber = 1
        repeat {
            Log.breadcrumb(category: "sync.archive", level: .debug, message: "Loading page \(pageNumber)")
            let result = try await fetchPage(pagination)

            if case .started = initialDownloadState.value,
               let totalCount = result.data?.user?.savedItems?.totalCount,
               pagination.cursor == nil {
                initialDownloadState.send(.paginating(totalCount: min(totalCount, pagination.maxItems)))
            }
            try updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result, pageSize: SyncConstants.Archive.pageSize)
            Log.breadcrumb(category: "sync.archive", level: .debug, message: "Finished loading page \(pageNumber)")
            pageNumber += 1
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
            query.filter = .some(SavedItemsFilter(updatedSince: .some(Int(updatedSince))))
        } else {
            query.filter = .some(SavedItemsFilter(statuses: .some([.init(.archived)])))
        }

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(result: GraphQLResult<FetchArchiveQuery.Data>) throws {
        guard let edges = result.data?.user?.savedItems?.edges,
              let cursor = result.data?.user?.savedItems?.pageInfo.endCursor else {
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
                item.update(from: node.fragments.savedItemSummary, with: space)
                if item.deletedAt != nil {
                    space.delete(item)
                }
            }
        }

        space.performAndWait {
            persistentTask.currentCursor = cursor
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

        init(maxItems: Int, pageSize: Int, cursor: String) {
            self.init(cursor: cursor, shouldFetchNextPage: false, maxItems: maxItems, pageSize: pageSize)
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
