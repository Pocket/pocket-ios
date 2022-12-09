import Apollo
import Foundation
import PocketGraph
import SharedPocketKit
import Combine

public protocol SearchService: AnyObject {
    var results: Published<[SearchSavedItemParts]>.Publisher { get }
    func search(for term: String, scope: SearchScope) async
}

public class PocketSearchService: SearchService {
    enum Constants {
        static let pageSize = 30
    }

    @Published
    private var _results: [SearchSavedItemParts] = []
    public var results: Published<[SearchSavedItemParts]>.Publisher { $_results }

    private let apollo: ApolloClientProtocol

    init(apollo: ApolloClientProtocol) {
        self.apollo = apollo
    }

    public func search(for term: String, scope: SearchScope) async {
        do {
            try await fetch(for: term, scope: scope)
        } catch {
            // TODO: How to handle errors
            Crashlogger.capture(error: error)
        }
    }

    private func fetch(for term: String, scope: SearchScope) async throws {
        _results = []
        var shouldFetchNextPage = true
        var items: [SearchSavedItemParts] = []
        var pagination = PaginationInput(first: GraphQLNullable<Int>(integerLiteral: Constants.pageSize))

        while shouldFetchNextPage {
            let filter = getSearchFilter(with: scope)
            let query = SearchSavedItemsQuery(term: term, pagination: .init(pagination), filter: .some(filter))
            let result = try await apollo.fetch(query: query)
            result.data?.user?.searchSavedItems?.edges.forEach { edge in
                items.append(edge.node.savedItem.fragments.searchSavedItemParts)
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
