import Sync
import Combine
import SharedPocketKit
import PocketGraph

class MockSearchService: SearchService {
    @Published
    var _results: [SearchSavedItemParts] = []
    var results: Published<[SearchSavedItemParts]>.Publisher { $_results }

    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockSearchService {
    private static let search = "search"
    typealias SearchImpl = (String, SearchScope) -> Void

    struct SearchCall {
        let term: String
        let scope: SearchScope
    }

    func stubSearch(impl: @escaping SearchImpl) {
        implementations[Self.search] = impl
    }

    func search(for term: String, scope: SharedPocketKit.SearchScope) {
        guard let impl = implementations[Self.search] as? SearchImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.search] = (calls[Self.search] ?? []) + [
            SearchCall(term: term, scope: scope)
        ]

        impl(term, scope)
    }
}
