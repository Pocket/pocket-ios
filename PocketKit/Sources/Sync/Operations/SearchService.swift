import Apollo
import UIKit
import Foundation
import PocketGraph
import SharedPocketKit
import Combine

public enum SearchServiceError: Error {
    case noInternet
}

public protocol SearchService: AnyObject {
    var results: Published<[SearchSavedItem]?>.Publisher { get }
    func search(for term: String, scope: SearchScope) async throws
}

public struct SearchSavedItem {
    public var remoteItem: SavedItem.RemoteSavedItem
    public var item: SavedItem.RemoteSavedItem.Item
    public var cursor: String?

    init(remoteItem: SavedItem.RemoteSavedItem) {
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

    @Published
    private var _results: [SearchSavedItem]?

    public var results: Published<[SearchSavedItem]?>.Publisher { $_results }

    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    public func search(for term: String, scope: SearchScope) async throws {
        do {
            try await fetch(for: term, scope: scope)
        } catch {
            // TODO: How to handle errors
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
        var shouldFetchNextPage = true
        var items: [SearchSavedItem] = []
        var pagination = PaginationInput(first: GraphQLNullable<Int>(integerLiteral: Constants.pageSize))

        while shouldFetchNextPage {
            let filter = getSearchFilter(with: scope)
            let query = SearchSavedItemsQuery(term: term, pagination: .init(pagination), filter: .some(filter))
            let result = try await apollo.fetch(query: query)
            result.data?.user?.searchSavedItems?.edges.forEach { edge in
                var searchSavedItem = SearchSavedItem(remoteItem: edge.node.savedItem.fragments.savedItemReaderView)
                searchSavedItem.cursor = edge.cursor
                items.append(searchSavedItem)
            }
            if let pageInfo = result.data?.user?.searchSavedItems?.pageInfo {
                pagination.after = pageInfo.endCursor ?? .none
                shouldFetchNextPage = pageInfo.hasNextPage
            } else {
                shouldFetchNextPage = false
            }

            _results = items
        }
    }

    private func getSearchFilter(with scope: SearchScope) -> SearchFilterInput {
        switch scope {
        case .saves:
            return SearchFilterInput(status: .init(.unread))
        case .archive:
            return SearchFilterInput(status: .init(.archived))
        case .all:
            return SearchFilterInput()
        }
    }
}
