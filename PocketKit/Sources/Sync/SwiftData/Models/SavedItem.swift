// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class SavedItem {
    // #Unique<SavedItem>([\.url])
    var archivedAt: Date?
    var createdAt: Date
    var cursor: String?
    var deletedAt: Date?
    var isArchived: Bool = false
    var isFavorite: Bool = false
    var remoteID: String?
    var url: String
    var highlights: [Highlight]?
    var item: Item?
    @Relationship(inverse: \SavedItemUpdatedNotification.savedItem)
    var savedItemUpdatedNotification: SavedItemUpdatedNotification?
    @Relationship(inverse: \Tag.savedItems)
    var tags: [Tag]?
    @Relationship(inverse: \UnresolvedSavedItem.savedItem)
    var unresolvedSavedItem: UnresolvedSavedItem?
    public init(createdAt: Date, url: String) {
        self.createdAt = createdAt
        self.url = url
    }

// #warning("The property \"ordered\" on SavedItem:highlights is unsupported in SwiftData.")
// #warning("The property \"spotlight\" on SavedItem:item is unsupported in SwiftData.")
// #warning("The property \"ordered\" on SavedItem:tags is unsupported in SwiftData.")

}
