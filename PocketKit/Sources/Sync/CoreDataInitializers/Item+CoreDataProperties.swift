// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension Item {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var article: Article?
    @NSManaged public var datePublished: Date?
    @NSManaged public var domain: String?
    @NSManaged public var excerpt: String?
    @NSManaged public var givenURL: String
    @NSManaged public var imageness: String?
    @NSManaged public var isArticle: Bool
    @NSManaged public var language: String?
    @NSManaged public var remoteID: String
    @NSManaged public var resolvedURL: String?
    @NSManaged public var shortURL: String?
    @NSManaged public var timeToRead: NSNumber?
    @NSManaged public var wordCount: NSNumber?
    @NSManaged public var title: String?
    @NSManaged public var topImageURL: URL?
    @NSManaged public var videoness: String?
    @NSManaged public var authors: NSOrderedSet?
    @NSManaged public var collection: Collection?
    @NSManaged public var domainMetadata: DomainMetadata?
    @NSManaged public var images: NSOrderedSet?
    @NSManaged public var recommendation: Recommendation?
    @NSManaged public var savedItem: SavedItem?
    @NSManaged public var syndicatedArticle: SyndicatedArticle?
    @NSManaged public var collectionStories: NSSet?
    @NSManaged public var sharedWithYouItem: SharedWithYouItem?
}

// MARK: Generated accessors for authors
extension Item {
    @objc(insertObject:inAuthorsAtIndex:)
    @NSManaged public func insertIntoAuthors(_ value: Author, at idx: Int)

    @objc(removeObjectFromAuthorsAtIndex:)
    @NSManaged public func removeFromAuthors(at idx: Int)

    @objc(insertAuthors:atIndexes:)
    @NSManaged public func insertIntoAuthors(_ values: [Author], at indexes: NSIndexSet)

    @objc(removeAuthorsAtIndexes:)
    @NSManaged public func removeFromAuthors(at indexes: NSIndexSet)

    @objc(replaceObjectInAuthorsAtIndex:withObject:)
    @NSManaged public func replaceAuthors(at idx: Int, with value: Author)

    @objc(replaceAuthorsAtIndexes:withAuthors:)
    @NSManaged public func replaceAuthors(at indexes: NSIndexSet, with values: [Author])

    @objc(addAuthorsObject:)
    @NSManaged public func addToAuthors(_ value: Author)

    @objc(removeAuthorsObject:)
    @NSManaged public func removeFromAuthors(_ value: Author)

    @objc(addAuthors:)
    @NSManaged public func addToAuthors(_ values: NSOrderedSet)

    @objc(removeAuthors:)
    @NSManaged public func removeFromAuthors(_ values: NSOrderedSet)
}

// MARK: Generated accessors for images
extension Item {
    @objc(insertObject:inImagesAtIndex:)
    @NSManaged public func insertIntoImages(_ value: Image, at idx: Int)

    @objc(removeObjectFromImagesAtIndex:)
    @NSManaged public func removeFromImages(at idx: Int)

    @objc(insertImages:atIndexes:)
    @NSManaged public func insertIntoImages(_ values: [Image], at indexes: NSIndexSet)

    @objc(removeImagesAtIndexes:)
    @NSManaged public func removeFromImages(at indexes: NSIndexSet)

    @objc(replaceObjectInImagesAtIndex:withObject:)
    @NSManaged public func replaceImages(at idx: Int, with value: Image)

    @objc(replaceImagesAtIndexes:withImages:)
    @NSManaged public func replaceImages(at indexes: NSIndexSet, with values: [Image])

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSOrderedSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSOrderedSet)
}

// MARK: Generated accessors for collectionStories
extension Item {
    @objc(addCollectionStoriesObject:)
    @NSManaged public func addToCollectionStories(_ value: CollectionStory)

    @objc(removeCollectionStoriesObject:)
    @NSManaged public func removeFromCollectionStories(_ value: CollectionStory)

    @objc(addCollectionStories:)
    @NSManaged public func addToCollectionStories(_ values: NSSet)

    @objc(removeCollectionStories:)
    @NSManaged public func removeFromCollectionStories(_ values: NSSet)
}
