// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Combine
import SharedPocketKit

/// A type that can perform a premium online-only search by searching by tag, title, or content.
/// Currently, this is used during a premium search experiment.
class PremiumOnlineSearch {
    private let source: Source
    private let searchService: SearchService
    private var subscriptions: [AnyCancellable] = []
    private var cache: [SearchScope: [String: [PocketItem]]] = [:]

    var pageNumberLoaded: Int = 0

    @Published var results: Result<[PocketItem], Error>?

    init(source: Source) {
        self.source = source
        self.searchService = source.makeSearchService()
    }

    func hasCache(with term: String, scope: SearchScope) -> Bool {
        guard let cache = cache[scope] else { return false }
        return cache[term] != nil
    }

    func search(with term: String, scope: SearchScope, shouldLoadMoreResults: Bool = false) {
        guard SearchScope.premiumScopes.contains(scope) else {
            results = .success([])
            return
        }

        guard !hasCache(with: term, scope: scope) || shouldLoadMoreResults else {
            Log.debug("Load cache for search")
            if let scopeCache = cache[scope] {
                results = .success(scopeCache[term] ?? [])
            } else {
                results = .success([])
            }
            return
        }
        clear()
        searchService.results.dropFirst().sink { [weak self] items in
            guard let self, let items else { return }
            let searchItems = items.compactMap { PocketItem(item: $0) }
            pageNumberLoaded += 1
            guard var scopeCache = cache[scope], let currentItems = scopeCache[term] else {
                cache[scope] = [term: searchItems]
                results = .success(searchItems)
                return
            }

            scopeCache[term] = currentItems + searchItems
            cache[scope] = scopeCache
            results = .success(currentItems + searchItems)
        }.store(in: &subscriptions)

        Task {
            do {
                try await searchService.search(for: term, scope: scope)
            } catch {
                self.results = .failure(error)
            }
        }
    }

    private func clear() {
        subscriptions = []
    }

    var hasFinishedResults: Bool {
        searchService.hasFinishedResults
    }

    var lastEndCursor: String {
        searchService.lastEndCursor
    }
}
