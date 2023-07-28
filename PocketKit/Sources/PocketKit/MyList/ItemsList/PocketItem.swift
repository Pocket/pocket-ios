// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph

struct PocketItem {
    let item: ItemsListItem
    private let itemPresenter: ItemsListItemPresenter

    init(item: ItemsListItem) {
        self.item = item
        // `PocketItem` is used within the scope of search, so we can simply use isPending
        // since archive is only available online, anyways, so there's no additional logic needed
        self.itemPresenter = ItemsListItemPresenter(item: item, isDisabled: item.isPending)
    }

    var id: String? {
        item.id
    }

    var isFavorite: Bool {
        item.isFavorite
    }

    var isArchived: Bool {
        item.isArchived
    }

    var collection: NSAttributedString? {
        itemPresenter.attributedCollection
    }

    var title: NSAttributedString {
        itemPresenter.attributedTitle
    }

    var detail: NSAttributedString {
        itemPresenter.attributedDetail
    }

    var tags: [NSAttributedString]? {
        itemPresenter.attributedTags
    }

    var tagCount: NSAttributedString? {
        itemPresenter.attributedTagCount
    }

    var thumbnailURL: URL? {
        itemPresenter.thumbnailURL
    }

    var remoteItemParts: SavedItemParts? {
        item.remoteItemParts
    }

    var bestURL: String {
        item.bestURL
    }

    var savedItemURL: String {
        item.savedItemURL
    }

    var cursor: String? {
        item.cursor
    }

    var hasTags: Bool {
        (item.tagNames ?? []).isEmpty == false
    }
}
