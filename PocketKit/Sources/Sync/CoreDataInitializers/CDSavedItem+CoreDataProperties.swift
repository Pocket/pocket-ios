// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDSavedItem {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDSavedItem> {
        return NSFetchRequest<CDSavedItem>(entityName: "SavedItem")
    }

    @NSManaged public var archivedAt: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var cursor: String?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var isArchived: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var remoteID: String?
    @NSManaged public var url: String
    @NSManaged public var item: CDItem?
    @NSManaged public var savedItemUpdatedNotification: CDSavedItemUpdatedNotification?
    @NSManaged public var tags: NSOrderedSet?
    @NSManaged public var highlights: NSOrderedSet?
    @NSManaged public var unresolvedSavedItem: UnresolvedSavedItem?
}

// MARK: Generated accessors for tags
extension CDSavedItem {
    @objc(insertObject:inTagsAtIndex:)
    @NSManaged public func insertIntoTags(_ value: CDTag, at idx: Int)

    @objc(removeObjectFromTagsAtIndex:)
    @NSManaged public func removeFromTags(at idx: Int)

    @objc(insertTags:atIndexes:)
    @NSManaged public func insertIntoTags(_ values: [CDTag], at indexes: NSIndexSet)

    @objc(removeTagsAtIndexes:)
    @NSManaged public func removeFromTags(at indexes: NSIndexSet)

    @objc(replaceObjectInTagsAtIndex:withObject:)
    @NSManaged public func replaceTags(at idx: Int, with value: CDTag)

    @objc(replaceTagsAtIndexes:withTags:)
    @NSManaged public func replaceTags(at indexes: NSIndexSet, with values: [CDTag])

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: CDTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: CDTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSOrderedSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSOrderedSet)
}

// MARK: Convenience properties
extension CDSavedItem {
    public var hasHighlights: Bool {
        highlightsCount > 0
    }

    public var highlightsCount: Int {
        highlights?.count ?? 0
    }
}
