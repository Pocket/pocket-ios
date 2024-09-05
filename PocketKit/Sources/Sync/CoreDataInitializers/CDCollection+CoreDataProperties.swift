// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDCollection {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDCollection> {
        return NSFetchRequest<CDCollection>(entityName: "Collection")
    }

    @NSManaged public var intro: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var slug: String
    @NSManaged public var title: String?
    @NSManaged public var authors: NSOrderedSet?
    @NSManaged public var stories: NSOrderedSet?
    @NSManaged public var item: Item?
}

// MARK: Generated accessors for authors
extension CDCollection {
    @objc(insertObject:inAuthorsAtIndex:)
    @NSManaged public func insertIntoAuthors(_ value: CDCollectionAuthor, at idx: Int)

    @objc(removeObjectFromAuthorsAtIndex:)
    @NSManaged public func removeFromAuthors(at idx: Int)

    @objc(insertAuthors:atIndexes:)
    @NSManaged public func insertIntoAuthors(_ values: [CDCollectionAuthor], at indexes: NSIndexSet)

    @objc(removeAuthorsAtIndexes:)
    @NSManaged public func removeFromAuthors(at indexes: NSIndexSet)

    @objc(replaceObjectInAuthorsAtIndex:withObject:)
    @NSManaged public func replaceAuthors(at idx: Int, with value: CDCollectionAuthor)

    @objc(replaceAuthorsAtIndexes:withAuthors:)
    @NSManaged public func replaceAuthors(at indexes: NSIndexSet, with values: [CDCollectionAuthor])

    @objc(addAuthorsObject:)
    @NSManaged public func addToAuthors(_ value: CDCollectionAuthor)

    @objc(removeAuthorsObject:)
    @NSManaged public func removeFromAuthors(_ value: CDCollectionAuthor)

    @objc(addAuthors:)
    @NSManaged public func addToAuthors(_ values: NSOrderedSet)

    @objc(removeAuthors:)
    @NSManaged public func removeFromAuthors(_ values: NSOrderedSet)
}

// MARK: Generated accessors for stories
extension CDCollection {
    @objc(insertObject:inStoriesAtIndex:)
    @NSManaged public func insertIntoStories(_ value: CDCollectionStory, at idx: Int)

    @objc(removeObjectFromStoriesAtIndex:)
    @NSManaged public func removeFromStories(at idx: Int)

    @objc(insertStories:atIndexes:)
    @NSManaged public func insertIntoStories(_ values: [CDCollectionStory], at indexes: NSIndexSet)

    @objc(removeStoriesAtIndexes:)
    @NSManaged public func removeFromStories(at indexes: NSIndexSet)

    @objc(replaceObjectInStoriesAtIndex:withObject:)
    @NSManaged public func replaceStories(at idx: Int, with value: CDCollectionStory)

    @objc(replaceStoriesAtIndexes:withStories:)
    @NSManaged public func replaceStories(at indexes: NSIndexSet, with values: [CDCollectionStory])

    @objc(addStoriesObject:)
    @NSManaged public func addToStories(_ value: CDCollectionStory)

    @objc(removeStoriesObject:)
    @NSManaged public func removeFromStories(_ value: CDCollectionStory)

    @objc(addStories:)
    @NSManaged public func addToStories(_ values: NSOrderedSet)

    @objc(removeStories:)
    @NSManaged public func removeFromStories(_ values: NSOrderedSet)
}
