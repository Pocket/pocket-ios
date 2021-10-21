// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData


extension SavedItem {
    typealias RemoteSavedItem = SavedItemParts
    typealias RemoteItem = ItemParts

    func update(from remote: RemoteSavedItem) {
        remoteID = remote.remoteId
        url = URL(string: remote.url)
        createdAt = Date(timeIntervalSince1970: TimeInterval(remote._createdAt))
        deletedAt = remote._deletedAt.flatMap { Date(timeIntervalSince1970: TimeInterval($0)) }
        isArchived = remote.isArchived
        isFavorite = remote.isFavorite

        guard let context = managedObjectContext,
            let itemParts = remote.item.fragments.itemParts else {
            return
        }

        item = Item(context: context)
        item?.update(remote: itemParts)
    }
}
