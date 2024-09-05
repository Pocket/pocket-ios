// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo
import UIKit
import Foundation
import PocketGraph
import SharedPocketKit
import Combine

public enum SearchServiceError: LoggableError {
    case noInternet

    public var logDescription: String {
        switch self {
        case .noInternet: return "No internet"
        }
    }
}

public protocol SearchService: AnyObject {
    var results: Published<[SearchSavedItem]?>.Publisher { get }
    func search(for term: String, scope: SearchScope) async throws
    var hasFinishedResults: Bool { get }
    var lastEndCursor: String { get }
}

public struct SearchSavedItem {
    public var remoteItem: CDSavedItem.RemoteSavedItem
    public var item: CDSavedItem.RemoteSavedItem.Item
    public var cursor: String?

    init(remoteItem: CDSavedItem.RemoteSavedItem) {
        self.remoteItem = remoteItem
        self.item = remoteItem.item
    }
}

public class PocketSearchService: SearchService {
    enum Constants {
        static var pageSize: Int {
            UIDevice.current.userInterfaceIdiom == .phone ? 30 : 50
        }
        // This error code is returned from Apollo when there is a no internet connection
        static let noConnectionErrorCode = -1009
    }

    typealias SearchItemEdge = SearchSavedItemsQuery.Data.User.SearchSavedItems.Edge

    @Published private var _results: [SearchSavedItem]?
    public var results: Published<[SearchSavedItem]?>.Publisher { $_results }

    public var hasFinishedResults: Bool = false
    public var lastEndCursor: String = ""

    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    /// Main search function to fetch items from GraphQL response
    /// - Parameters:
    ///   - term: search term that the user input in the text field
    ///   - scope: search scope that the user is on (i.e. saves, archive, all items)
    /// - Returns: list of items for a specific search term
    public func search(for term: String, scope: SearchScope) async throws {
        do {
            try await fetch(for: term, scope: scope)
        } catch {
            Log.capture(error: error)
            if case URLSessionClient.URLSessionClientError.networkError(_, _, let underlying) = error {
                switch (underlying as NSError).code {
                case Constants.noConnectionErrorCode:
                    throw SearchServiceError.noInternet
                default:
                    throw error
                }
            }
            throw error
        }
    }

    private func fetch(for term: String, scope: SearchScope) async throws {
        guard !hasFinishedResults else {
            Log.debug("Search has reached the end of paginated results")
            return
        }

        var items: [SearchSavedItem] = []
        let pagination = PaginationInput(after: GraphQLNullable<String>(stringLiteral: lastEndCursor), first: GraphQLNullable<Int>(integerLiteral: Constants.pageSize))

        let filter = getSearchFilter(with: scope)
        let sortOrder = getSortOrder()
        let query = SearchSavedItemsQuery(term: getTerm(term, for: scope), pagination: .init(pagination), filter: .some(filter), sort: .some(sortOrder))
        let result = try await apollo.fetch(query: query)
        result.data?.user?.searchSavedItems?.edges.forEach { edge in
            var searchSavedItem = SearchSavedItem(remoteItem: edge.node.savedItem.fragments.savedItemParts)
            searchSavedItem.cursor = edge.cursor
            items.append(searchSavedItem)
        }

        if let pageInfo = result.data?.user?.searchSavedItems?.pageInfo {
            hasFinishedResults = !pageInfo.hasNextPage
            lastEndCursor = pageInfo.endCursor ?? ""
        }

        _results = items
    }

    private func getSearchFilter(with scope: SearchScope) -> SearchFilterInput {
        switch scope {
        case .saves:
            return SearchFilterInput(status: .init(.unread))
        case .archive:
            return SearchFilterInput(status: .init(.archived))
        case .all:
            return SearchFilterInput()
        case .premiumSearchByTitle:
            return SearchFilterInput(onlyTitleAndURL: true)
        case .premiumSearchByTag:
            return SearchFilterInput()
        case .premiumSearchByContent:
            return SearchFilterInput()
        }
    }

    private func getSortOrder() -> SearchSortInput {
        return SearchSortInput(sortBy: .init(.createdAt), sortOrder: .init(.desc))
    }

    func getTerm(_ term: String, for scope: SearchScope) -> String {
        switch scope {
        case .all, .saves, .archive, .premiumSearchByTitle, .premiumSearchByContent: return term
        // For now, assume that tags uses the search bar text as a single tag term.
        // Support for multiple tags may come later.
        case .premiumSearchByTag:
            // Searching by tag uses custom operators:
            // https://support.mozilla.org/en-US/kb/searching-for-tags-with-pocket-premium
            // So, if the user has already prefixed their search term appropriately,
            // then the term doesn't have to be generated
            if term.hasPrefix("tag:") || term.hasPrefix("#") {
                return term
            }
            return "tag:\"\(term)\""
        }
    }
}
