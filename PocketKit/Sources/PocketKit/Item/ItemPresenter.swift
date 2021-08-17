// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Combine
import Foundation
import Sync


class ItemPresenter: ItemRow {
    @Published
    private var item: Item
    
    let index: Int

    private let source: Source

    init(item: Item, index: Int, source: Source) {
        self.item = item
        self.index = index
        self.source = source
    }

    public var title: String {
        [item.title, item.url?.absoluteString]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    public var detail: String {
        [domain, timeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    public var domain: String? {
        item.domainMetadata?.name ?? item.domain
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

    func favorite() {
        source.favorite(item: item)
    }

    func unfavorite() {
        source.unfavorite(item: item)
    }

    func archive() {
        source.archive(item: item)
    }

    func delete() {
        source.delete(item: item)
    }
}
