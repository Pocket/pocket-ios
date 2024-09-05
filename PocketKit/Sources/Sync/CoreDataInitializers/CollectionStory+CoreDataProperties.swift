// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CollectionStory {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CollectionStory> {
        return NSFetchRequest<CollectionStory>(entityName: "CollectionStory")
    }

    @NSManaged public var excerpt: String
    @NSManaged public var title: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var url: String
    @NSManaged public var publisher: String?
    @NSManaged public var sortOrder: NSNumber?
    @NSManaged public var authors: NSOrderedSet
    @NSManaged public var collection: CDCollection?
    @NSManaged public var item: Item?
}

// MARK: Generated accessors for authors
extension CollectionStory {
    @objc(insertObject:inAuthorsAtIndex:)
    @NSManaged public func insertIntoAuthors(_ value: CollectionAuthor, at idx: Int)

    @objc(removeObjectFromAuthorsAtIndex:)
    @NSManaged public func removeFromAuthors(at idx: Int)

    @objc(insertAuthors:atIndexes:)
    @NSManaged public func insertIntoAuthors(_ values: [CollectionAuthor], at indexes: NSIndexSet)

    @objc(removeAuthorsAtIndexes:)
    @NSManaged public func removeFromAuthors(at indexes: NSIndexSet)

    @objc(replaceObjectInAuthorsAtIndex:withObject:)
    @NSManaged public func replaceAuthors(at idx: Int, with value: CollectionAuthor)

    @objc(replaceAuthorsAtIndexes:withAuthors:)
    @NSManaged public func replaceAuthors(at indexes: NSIndexSet, with values: [CollectionAuthor])

    @objc(addAuthorsObject:)
    @NSManaged public func addToAuthors(_ value: CollectionAuthor)

    @objc(removeAuthorsObject:)
    @NSManaged public func removeFromAuthors(_ value: CollectionAuthor)

    @objc(addAuthors:)
    @NSManaged public func addToAuthors(_ values: NSOrderedSet)

    @objc(removeAuthors:)
    @NSManaged public func removeFromAuthors(_ values: NSOrderedSet)
}
