// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class SavedItem {
    // #Unique<SavedItem>([\.url])
    public var archivedAt: Date?
    public var createdAt: Date
    public var cursor: String?
    public var deletedAt: Date?
    public var isArchived: Bool = false
    public var isFavorite: Bool = false
    public var remoteID: String?
    public var url: String
    public var highlights: [Highlight]?
    public var item: Item?
    @Relationship(inverse: \SavedItemUpdatedNotification.savedItem)
    public var savedItemUpdatedNotification: SavedItemUpdatedNotification?
    @Relationship(inverse: \Tag.savedItems)
    public var tags: [Tag]?
    @Relationship(inverse: \UnresolvedSavedItem.savedItem)
    public var unresolvedSavedItem: UnresolvedSavedItem?
    public init(createdAt: Date, url: String) {
        self.createdAt = createdAt
        self.url = url
    }

// #warning("The property \"ordered\" on SavedItem:highlights is unsupported in SwiftData.")
// #warning("The property \"spotlight\" on SavedItem:item is unsupported in SwiftData.")
// #warning("The property \"ordered\" on SavedItem:tags is unsupported in SwiftData.")

}
