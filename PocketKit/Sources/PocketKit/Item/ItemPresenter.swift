// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Combine
import Foundation


class ItemPresenter: ItemRow {
    @Published
    private var item: Item
    
    let index: Int

    init(item: Item, index: Int) {
        self.item = item
        self.index = index
    }

    public var title: String {
        [item.title, item.url?.absoluteString]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    public var domain: String {
        item.domainMetadata?.name ?? item.domain ?? ""
    }

    public var timeToRead: String? {
        item.timeToRead > 0 ? "\(item.timeToRead) min" : nil
    }

    public var thumbnailURL: URL? {
        item.thumbnailURL
    }

    public var isFavorite: Bool {
        item.isFavorite
    }
}
