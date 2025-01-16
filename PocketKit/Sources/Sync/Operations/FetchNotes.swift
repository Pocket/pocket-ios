// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit
import CoreData

class FetchNotes: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let initialDownloadState: CurrentValueSubject<InitialDownloadState, Never>
    private let lastRefresh: LastRefresh
    // Force unwrapping, because the entry point, execute, will ensure that this exists with a guard
    private var safeSpace: NotesSpace!

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
            if lastRefresh.lastRefreshNotes != nil {
                guard let lastRefreshTime = lastRefresh.lastRefreshNotes,
                      let lastRefreshDate = ISO8601DateFormatter.rfc3339WithFractionalSeconds.date(from: lastRefreshTime),
                      Date().timeIntervalSince(lastRefreshDate) > SyncConstants.Notes.timeMustPass else {
                    Log.info("Not refreshing notes from server, last refresh is not above tolerance of \(SyncConstants.Notes.timeMustPass) seconds")
                    return .success
                }
            }

            var firstSync = false
            if lastRefresh.lastRefreshNotes == nil {
                initialDownloadState.send(.started)
                firstSync = true
            }

            try await fetchNotes(firstSync: firstSync)
            lastRefresh.refreshedNotes()
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

    private func fetchNotes(firstSync: Bool) async throws {
        var pagination = PaginationSpec(
            maxItems: SyncConstants.Notes.firstLoadMaxCount,
            pageSize: SyncConstants.Notes.initalPageSize,
            cursor: safeSpace.currentCursor
        )

        var pageNumber = 1
        var totalToDownload = SyncConstants.Notes.firstLoadMaxCount
        repeat {
            let result = try await fetchPage(pagination)

            if let totalCount = result.data?.notes?.totalCount,
               firstSync {
                if pageNumber == 1 {
                    totalToDownload = min(totalCount, totalToDownload)
                }
                let totalReaminingToDownload = min(totalToDownload, pagination.maxRemainingItemsAllowedToDownload)
                let progress = Float(totalToDownload - totalReaminingToDownload) / Float(totalToDownload)
                Log.breadcrumb(category: "sync.notes", level: .debug, message: "Download Progress: \(progress) - Remaining Downloading: \(totalReaminingToDownload)")
                initialDownloadState.send(.paginating(totalCount: totalReaminingToDownload, currentPercentProgress: progress))
            }

            try updateLocalStorage(result: result)
            pagination = pagination.nextPage(result: result, pageSize: SyncConstants.Notes.pageSize)
            Log.breadcrumb(category: "sync.notes", level: .debug, message: "Finsihed loading page \(pageNumber)")
            pageNumber += 1
        } while pagination.shouldFetchNextPage

        initialDownloadState.send(.completed)
    }

    private func fetchPage(_ pagination: PaginationSpec) async throws -> GraphQLResult<NotesQuery.Data> {
        let query = NotesQuery(
            pagination: .some(
                PaginationInput(
                    after: pagination.cursor ?? .none,
                    first: .some(pagination.pageSize)
                )
            ), filter: .none
        )

        if let updatedSince = lastRefresh.lastRefreshNotes {
            query.filter = .some(NoteFilterInput(since: .some(updatedSince)))
        } else {
            query.filter = .none
        }

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(result: GraphQLResult<NotesQuery.Data>) throws {
        guard let edges = result.data?.notes?.edges,
              let cursor = result.data?.notes?.pageInfo.endCursor else {
            return
        }
        try safeSpace.updateNotes(edges: edges, cursor: cursor)
    }

    struct PaginationSpec {
        let cursor: String?
        let shouldFetchNextPage: Bool
        let maxRemainingItemsAllowedToDownload: Int
        let pageSize: Int

        init(maxItems: Int, pageSize: Int, cursor: String? = nil) {
            self.init(cursor: cursor, shouldFetchNextPage: false, maxRemainingItemsAllowedToDownload: maxItems, pageSize: pageSize)
        }

        private init(cursor: String?, shouldFetchNextPage: Bool, maxRemainingItemsAllowedToDownload: Int, pageSize: Int) {
            self.cursor = cursor
            self.shouldFetchNextPage = shouldFetchNextPage
            self.maxRemainingItemsAllowedToDownload = maxRemainingItemsAllowedToDownload
            self.pageSize = pageSize
        }

        func nextPage(result: GraphQLResult<NotesQuery.Data>, pageSize: Int) -> PaginationSpec {
            guard let notes = result.data?.notes,
                  let itemCount = notes.edges?.count,
                  let endCursor = notes.pageInfo.endCursor else {
                return PaginationSpec(cursor: nil, shouldFetchNextPage: false, maxRemainingItemsAllowedToDownload: maxRemainingItemsAllowedToDownload, pageSize: pageSize)
            }

            return PaginationSpec(
                cursor: endCursor,
                shouldFetchNextPage: notes.pageInfo.hasNextPage && itemCount < maxRemainingItemsAllowedToDownload,
                maxRemainingItemsAllowedToDownload: min((maxRemainingItemsAllowedToDownload - itemCount), notes.totalCount),
                pageSize: pageSize
            )
        }
    }
}
