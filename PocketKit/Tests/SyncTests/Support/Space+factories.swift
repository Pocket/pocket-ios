// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
@testable import Sync

extension Space {
    @discardableResult
    func seedItem(
        itemID: String = "the-item-id",
        url: String = "http://example.com/item-1",
        title: String = "Item 1",
        isFavorite: Bool = false
    ) throws -> Item {
        let item = newItem()
        item.itemID = itemID
        item.url = URL(string: url)!
        item.title = title
        item.isFavorite = isFavorite

        try save()
        return item
    }
}
