// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Combine
import PocketGraph
import SharedPocketKit
import CoreData

class FetchSharedWithYouItems: SyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let urls: [String]

    // Force unwrapping, because the entry point, execute, will ensure that this exists with a guard
    private var safeSpace: SharedWithYouSpace!

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        urls: [String]
    ) {
        self.apollo = apollo
        self.space = space
        self.urls = urls
    }

    func execute(syncTaskId: NSManagedObjectID) async -> SyncOperationResult {
        guard let safeSpace = DerivedSpace(space: space, taskID: syncTaskId) else {
            return .retry(NoPersistentTaskOperationError())
        }
        self.safeSpace = safeSpace

        do {
            try await fetchSharedWithYouItems(urls: urls)
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
                        message: "ResponseCodeInterceptor.ResponseCodeError with Error: \(error) and status code \(String(describing: response?.statusCode))"
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

    private func fetchSharedWithYouItems(urls: [String]) async throws {
        for url in urls.enumerated() {
            Log.breadcrumb(category: "sync.sharedWithYou", level: .debug, message: "Grabbing sharedWithYouItem \(url.offset)")
            let sharedWithYouUrl = url.element
            // item url, that might require to be resolved from a short url
            var itemUrl = url.element
            // for short urls, attempt to find a related saved item mapped to any of the urls, otherwise just use the given url
            if URLComponents(string: itemUrl)?.isShortUrl == true {
                let resolvedData = try await apollo.fetch(query: ResolveItemUrlQuery(url: itemUrl)).data
                if let savedItemUrl = resolvedData?.itemByUrl?.savedItem?.url,
                   try space.fetchSavedItem(byURL: savedItemUrl, context: space.backgroundContext) != nil {
                    itemUrl = savedItemUrl
                } else if let resolvedUrl = resolvedData?.itemByUrl?.resolvedUrl,
                            try space.fetchSavedItem(byURL: resolvedUrl, context: space.backgroundContext) != nil {
                    itemUrl = resolvedUrl
                } else if let normalUrl = resolvedData?.itemByUrl?.normalUrl,
                          let savedItem = try space.fetchSavedItem(byURL: normalUrl, context: space.backgroundContext),
                          savedItem.item != nil {
                    itemUrl = normalUrl
                } else if let currentItemUrl = resolvedData?.itemByUrl?.givenUrl {
                    itemUrl = currentItemUrl
                }
            }

            if let item = try self.space.fetchSharedWithYouItem(with: sharedWithYouUrl, in: space.backgroundContext)?.item {
                Log.breadcrumb(category: "sync.sharedWithYou", level: .debug, message: "Skipping sharedWithYouItem \(url.offset) because we already have its data, itemId: \(item.remoteID)")
                continue
            }

            let result = try await fetchSharedWithYouSummary(itemUrl)
            try updateLocalStorage(url: url.element, sortOrder: url.offset, result: result)

            Log.breadcrumb(category: "sync.sharedWithYou", level: .debug, message: "Finsihed sharedWithYouItem \(url.offset), itemId: \(result.data?.itemByUrl?.fragments.compactItem.remoteID ?? "not found")")
        }

        try self.safeSpace.cleanupSharedWithYouItems(validUrls: urls)
    }

    private func fetchSharedWithYouSummary(_ url: String) async throws -> GraphQLResult<SharedWithYouSummaryQuery.Data> {
        let query = SharedWithYouSummaryQuery(
            url: url
        )

        return try await apollo.fetch(query: query)
    }

    private func updateLocalStorage(url: String, sortOrder: Int, result: GraphQLResult<SharedWithYouSummaryQuery.Data>) throws {
        guard let itemSummary = result.data?.itemByUrl?.fragments.compactItem else {
            return
        }

        try self.safeSpace.updateSharedWithYouItem(url: url, sortOrder: sortOrder, remote: itemSummary)
    }
}

private extension URLComponents {
    var isShortUrl: Bool {
        host == "pocket.co"
    }
}
