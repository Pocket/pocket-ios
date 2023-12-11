// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit
import CoreData

class FetchSaves: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    private let lastRefresh: LastRefresh
    // Force unwrapping, because the entry point, execute, will ensure that this exists with a guard
    private var safeSpace: SavedItemSpace!

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
        guard let safeSpace = DerivedSpace(space: space, taskID: syncTaskId) else {
            return .retry(NoPersistentTaskOperationError())
        }
        self.safeSpace = safeSpace

        do {
            if lastRefresh.lastRefreshSaves != nil {
                guard let lastRefreshTime = lastRefresh.lastRefreshSaves, Date().timeIntervalSince1970 - Double(lastRefreshTime) > SyncConstants.Saves.timeMustPass else {
                    Log.info("Not refreshing saves from server, last refresh is not above tolerance of \(SyncConstants.Saves.timeMustPass) seconds")
                    // Future TODO: We should have a new result called too soon that the ui can act on.
                    // However many states may not come from a user, IE. Instant Sync, Persistent Tasks that never finished, Retries
                    return .success
                }
            }

            var firstSync = false
            if lastRefresh.lastRefreshSaves == nil {
                initialDownloadState.send(.started)
                firstSync = true
            }

            try await fetchSaves(firstSync: firstSync)
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
                    return .failure(error)
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

    private func fetchSaves(firstSync: Bool) async throws {
        var pagination = PaginationSpec(maxItems: SyncConstants.Saves.firstLoadMaxCount, pageSize: SyncConstants.Saves.initalPageSize)
        if let cursor = safeSpace.currentCursor {
            pagination = PaginationSpec(maxItems: SyncConstants.Saves.firstLoadMaxCount, pageSize: SyncConstants.Saves.initalPageSize, cursor: cursor)
        }

        var i = 1
        var totalToDownload = SyncConstants.Saves.firstLoadMaxCount
        repeat {
            let result = try await fetchPage(pagination)

            if let totalCount = result.data?.user?.savedItems?.totalCount,
               firstSync {
                if i == 1 {
                    totalToDownload = min(totalCount, totalToDownload)
                }
                let totalReaminingToDownload = min(totalToDownload, pagination.maxRemainingItemsAllowedToDownload)
                let progress = Float(totalToDownload - totalReaminingToDownload) / Float(totalToDownload)
                Log.breadcrumb(category: "sync.saves", level: .debug, message: "Download Progress: \(progress) - Remaining Downloading: \(totalReaminingToDownload)")
                initialDownloadState.send(.paginating(totalCount: totalReaminingToDownload, currentPercentProgress: progress))
            }

            try updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result, pageSize: SyncConstants.Saves.pageSize)
            Log.breadcrumb(category: "sync.saves", level: .debug, message: "Finsihed loading page \(i)")
            i = i + 1
        } while pagination.shouldFetchNextPage

        initialDownloadState.send(.completed)
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
            query.savedItemsFilter = .some(SavedItemsFilter(updatedSince: .some(Int(updatedSince))))
        } else {
            query.savedItemsFilter = .some(SavedItemsFilter(status: .init(.unread)))
        }

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(result: GraphQLResult<FetchSavesQuery.Data>) throws {
        guard let edges = result.data?.user?.savedItems?.edges,
              let cursor = result.data?.user?.savedItems?.pageInfo.endCursor else {
            return
        }
        try safeSpace.updateSavedItems(edges: edges, cursor: cursor)
    }

    struct PaginationSpec {
        let cursor: String?
        let shouldFetchNextPage: Bool
        let maxRemainingItemsAllowedToDownload: Int
        let pageSize: Int

        init(maxItems: Int, pageSize: Int) {
            self.init(cursor: nil, shouldFetchNextPage: false, maxRemainingItemsAllowedToDownload: maxItems, pageSize: pageSize)
        }

        init(maxItems: Int, pageSize: Int, cursor: String) {
            self.init(cursor: cursor, shouldFetchNextPage: false, maxRemainingItemsAllowedToDownload: maxItems, pageSize: pageSize)
        }

        private init(cursor: String?, shouldFetchNextPage: Bool, maxRemainingItemsAllowedToDownload: Int, pageSize: Int) {
            self.cursor = cursor
            self.shouldFetchNextPage = shouldFetchNextPage
            self.maxRemainingItemsAllowedToDownload = maxRemainingItemsAllowedToDownload
            self.pageSize = pageSize
        }

        func nextPage(result: GraphQLResult<FetchSavesQuery.Data>, pageSize: Int) -> PaginationSpec {
            guard let savedItems = result.data?.user?.savedItems,
                  let itemCount = savedItems.edges?.count,
                  let endCursor = savedItems.pageInfo.endCursor else {
                return PaginationSpec(cursor: nil, shouldFetchNextPage: false, maxRemainingItemsAllowedToDownload: maxRemainingItemsAllowedToDownload, pageSize: pageSize)
            }

            return PaginationSpec(
                cursor: endCursor,
                shouldFetchNextPage: savedItems.pageInfo.hasNextPage && itemCount < maxRemainingItemsAllowedToDownload,
                maxRemainingItemsAllowedToDownload: min((maxRemainingItemsAllowedToDownload - itemCount), savedItems.totalCount),
                pageSize: pageSize
            )
        }
    }
}
