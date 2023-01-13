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
    private var cache: [String: [SearchItem]] = [:]
    private let scope: SearchScope

    @Published
    var results: [SearchItem]? {
        didSet {
            subscriptions = []
        }
    }

    init(source: Source, scope: SearchScope) {
        self.source = source
        self.searchService = source.makeSearchService()
        self.scope = scope
    }

    func search(with term: String) {
        guard cache[term] == nil else {
            results = cache[term] ?? []
            return
        }

        searchService.results.sink { [weak self] items in
            guard let self else { return }
            let searchItems = items.compactMap { SearchItem(item: $0) }
            self.cache[term] = searchItems
            self.results = self.cache[term] ?? []
        }.store(in: &subscriptions)

        Task {
            await searchService.search(for: term, scope: scope)
        }
    }

    func clear() {
        cache = [:]
        subscriptions = []
    }
}
