// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Analytics

class LocalSavesSearch {
    private let source: Source

    init(source: Source) {
        self.source = source
    }

    func search(with term: String) -> [PocketItem] {
        let items = source.searchSaves(search: term)?.compactMap { PocketItem(item: $0) } ?? []
        return items
    }
}
