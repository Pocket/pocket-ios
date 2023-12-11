// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit
import CoreData

class FetchSharedWithYouHighlights: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let sharedWithYouHighlights: [PocketSWHighlight]
    // Force unwrapping, because the entry point, execute, will ensure that this exists with a guard
    private var safeSpace: SharedWithYouSpace!

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        sharedWithYouHighlights: [PocketSWHighlight]
    ) {
        self.apollo = apollo
        self.space = space
        self.sharedWithYouHighlights = sharedWithYouHighlights
    }

    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult {
        guard let safeSpace = DerivedSpace(space: space, taskID: syncTaskId) else {
            return .retry(NoPersistentTaskOperationError())
        }
        self.safeSpace = safeSpace

        do {
            try await fetchSharedWithYouHighlights(pocketSWHighlights: self.sharedWithYouHighlights)
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
                return .failure(error)
            }
        }
    }

    private func fetchSharedWithYouHighlights(pocketSWHighlights: [PocketSWHighlight]) async throws {
        for pocketSWHighlight in pocketSWHighlights {
            Log.breadcrumb(category: "sync.sharedWithYou", level: .debug, message: "Grabbing sharedWithYouHighlight \(String(describing: pocketSWHighlight.index))")

            if let item = (try? self.space.fetchSharedWithYouHighlight(with: pocketSWHighlight.url, in: space.backgroundContext))?.item {
                Log.breadcrumb(category: "sync.sharedWithYou", level: .debug, message: "Skipping sharedWithYouHighlight \(String(describing: pocketSWHighlight.index)) because we already have it's data, itemId: \(item.remoteID)")
                continue
            }

            let result = try await fetchSharedWithYouSummary(pocketSWHighlight)
            try updateLocalStorage(highlight: pocketSWHighlight, result: result)

            Log.breadcrumb(category: "sync.sharedWithYou", level: .debug, message: "Finsihed sharedWithYouHighlight \(String(describing: pocketSWHighlight.index)), itemId: \(String(describing: result.data?.itemByUrl?.fragments.itemSummary.remoteID))")
        }

        try self.safeSpace.batchDeleteSharedWithYouHighlightsNotInArray(urls: pocketSWHighlights.compactMap { $0.url })
    }

    private func fetchSharedWithYouSummary(_ sharedWithYouHighlight: PocketSWHighlight) async throws -> GraphQLResult<SharedWithYouSummaryQuery.Data> {
        let query = SharedWithYouSummaryQuery(
            url: sharedWithYouHighlight.url.absoluteString
        )

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(highlight: PocketSWHighlight, result: GraphQLResult<SharedWithYouSummaryQuery.Data>) throws {
        guard let itemSummary = result.data?.itemByUrl?.fragments.itemSummary else {
            return
        }

        try self.safeSpace.updateSharedWithYouHighlight(highlight: highlight, with: itemSummary)
    }
}
