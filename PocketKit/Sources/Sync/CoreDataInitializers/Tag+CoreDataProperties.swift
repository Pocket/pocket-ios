// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension Tag {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String
    @NSManaged public var remoteID: String?
    @NSManaged public var savedItems: NSOrderedSet?
}

// MARK: Generated accessors for savedItems
extension Tag {
    @objc(insertObject:inSavedItemsAtIndex:)
    @NSManaged public func insertIntoSavedItems(_ value: SavedItem, at idx: Int)

    @objc(removeObjectFromSavedItemsAtIndex:)
    @NSManaged public func removeFromSavedItems(at idx: Int)

    @objc(insertSavedItems:atIndexes:)
    @NSManaged public func insertIntoSavedItems(_ values: [SavedItem], at indexes: NSIndexSet)

    @objc(removeSavedItemsAtIndexes:)
    @NSManaged public func removeFromSavedItems(at indexes: NSIndexSet)

    @objc(replaceObjectInSavedItemsAtIndex:withObject:)
    @NSManaged public func replaceSavedItems(at idx: Int, with value: SavedItem)

    @objc(replaceSavedItemsAtIndexes:withSavedItems:)
    @NSManaged public func replaceSavedItems(at indexes: NSIndexSet, with values: [SavedItem])

    @objc(addSavedItemsObject:)
    @NSManaged public func addToSavedItems(_ value: SavedItem)

    @objc(removeSavedItemsObject:)
    @NSManaged public func removeFromSavedItems(_ value: SavedItem)

    @objc(addSavedItems:)
    @NSManaged public func addToSavedItems(_ values: NSOrderedSet)

    @objc(removeSavedItems:)
    @NSManaged public func removeFromSavedItems(_ values: NSOrderedSet)
}
