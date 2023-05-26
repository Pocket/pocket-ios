// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Combine
import SharedPocketKit
import PocketGraph

class MockSearchService: SearchService {
    @Published var _results: [SearchSavedItem]? = []
    var results: Published<[SearchSavedItem]?>.Publisher { $_results }

    public var hasFinishedResults: Bool = false
    public var lastEndCursor: String = ""

    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockSearchService {
    private static let search = "search"
    typealias SearchImpl = (String, SearchScope) throws -> Void

    struct SearchCall {
        let term: String
        let scope: SearchScope
    }

    func stubSearch(impl: @escaping SearchImpl) {
        implementations[Self.search] = impl
    }

    func search(for term: String, scope: SharedPocketKit.SearchScope) async throws {
        guard let impl = implementations[Self.search] as? SearchImpl else {
            fatalError("\(Self.self)#\(#function) has not been stubbed")
        }

        calls[Self.search] = (calls[Self.search] ?? []) + [
            SearchCall(term: term, scope: scope)
        ]

        try impl(term, scope)
    }

    func searchCall(at index: Int) -> SearchCall? {
        guard let calls = calls[Self.search], calls.count > index else {
            return nil
        }

        return calls[index] as? SearchCall
    }
}
