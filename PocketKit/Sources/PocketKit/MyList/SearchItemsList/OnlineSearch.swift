// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Combine
import SharedPocketKit

class OnlineSearch {
    private let source: Source
    private let searchService: SearchService
    private var subscriptions: [AnyCancellable] = []
    private var cache: [String: [PocketItem]] = [:]
    private let scope: SearchScope

    @Published
    var results: Result<[PocketItem], Error>?

    init(source: Source, scope: SearchScope) {
        self.source = source
        self.searchService = source.makeSearchService()
        self.scope = scope
    }

    func hasCache(with term: String) -> Bool {
        cache[term] != nil
    }

    func search(with term: String) {
        guard !hasCache(with: term) else {
            results = .success(cache[term] ?? [])
            return
        }

        searchService.results.sink { [weak self] items in
            guard let self, let items else { return }
            let searchItems = items.compactMap { PocketItem(item: $0) }
            self.cache[term] = searchItems
            self.results = .success(self.cache[term] ?? [])
        }.store(in: &subscriptions)

        Task {
            do {
                try await searchService.search(for: term, scope: scope)
            } catch {
                self.results = .failure(error)
            }
        }
    }
}
