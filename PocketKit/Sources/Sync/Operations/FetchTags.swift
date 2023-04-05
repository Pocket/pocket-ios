// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit
import CoreData

/// Note: This class should only be used to fetch tags on login of a user or if the use does a manual pull to refresh.
/// After initial login, requesting saves/archives via the updatedSince filter will pull in all new/changed tags associated with any save.
/// We can not filter on tags updatedSince explicitly because in the server database, tags are not a real entity at the moment and need database modeling changes to support this.
class FetchTags: SyncOperation {

    private let apollo: ApolloClientProtocol
    private let space: Space
    private let events: SyncEvents
    private let lastRefresh: LastRefresh
    // Force unwrapping, because the entry point, execute, will ensure that this exists with a guard
    private var persistentTask: PersistentSyncTask!

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        events: SyncEvents,
        lastRefresh: LastRefresh
    ) {
        self.apollo = apollo
        self.space = space
        self.events = events
        self.lastRefresh = lastRefresh
    }

    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult {
        guard let persistentTask = space.backgroundObject(with: syncTaskId) as? PersistentSyncTask else {
            return .retry(NoPersistentTaskOperationError())
        }
        self.persistentTask = persistentTask

        do {
            try await fetchTags()
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

    private func fetchTags() async throws {
        var shouldFetchNextPage = true
        var pagination = PaginationInput(first: .null)

        var pageNumber = 1
        repeat {
            Log.breadcrumb(category: "sync.tags", level: .debug, message: "Loading page \(pageNumber)")
            let query = TagsQuery(pagination: .init(pagination))
            let result = try await apollo.fetch(query: query)
            if let pageInfo = result.data?.user?.tags?.pageInfo {
                pagination.after = pageInfo.endCursor ?? .none
                shouldFetchNextPage = pageInfo.hasNextPage
                persistentTask.currentCursor = pageInfo.endCursor
            } else {
                shouldFetchNextPage = false
            }
            try updateLocalTags(result)
            try space.save()

            Log.breadcrumb(category: "sync.tags", level: .debug, message: "Finsihed loading page \(pageNumber)")
            pageNumber += 1
        } while shouldFetchNextPage
    }

    func updateLocalTags(_ result: GraphQLResult<TagsQuery.Data>) throws {
        result.data?.user?.tags?.edges?.forEach { edge in
            guard let node = edge?.node else { return }
            space.performAndWait {
                let tag = space.fetchOrCreateTag(byName: node.name)
                tag.update(remote: node.fragments.tagParts)
            }
        }
    }
}
