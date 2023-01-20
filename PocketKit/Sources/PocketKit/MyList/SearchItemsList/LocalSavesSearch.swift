// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync

class LocalSavesSearch {
    private let source: Source
    private var cache: [String: [SearchItem]] = [:]

    init(source: Source) {
        self.source = source
    }

    func search(with term: String) -> [SearchItem] {
        guard cache[term] == nil else {
            return cache[term] ?? []
        }
        let items = source.searchSaves(search: term)?.compactMap { SearchItem(item: $0) } ?? []
        cache[term] = items
        return cache[term] ?? []
    }
}
