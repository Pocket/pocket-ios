// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
import Foundation
import CoreData

extension CDSlate {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDSlate> {
        return NSFetchRequest<CDSlate>(entityName: "Slate")
    }

    @NSManaged public var experimentID: String
    @NSManaged public var name: String?
    @NSManaged public var remoteID: String
    @NSManaged public var requestID: String
    @NSManaged public var slateDescription: String?
    @NSManaged public var recommendations: NSOrderedSet?
    @NSManaged public var slateLineup: CDSlateLineup?
    @NSManaged public var sortIndex: NSNumber?
}

// MARK: Generated accessors for recommendations
extension CDSlate {
    @objc(insertObject:inRecommendationsAtIndex:)
    @NSManaged public func insertIntoRecommendations(_ value: CDRecommendation, at idx: Int)

    @objc(removeObjectFromRecommendationsAtIndex:)
    @NSManaged public func removeFromRecommendations(at idx: Int)

    @objc(insertRecommendations:atIndexes:)
    @NSManaged public func insertIntoRecommendations(_ values: [CDRecommendation], at indexes: NSIndexSet)

    @objc(removeRecommendationsAtIndexes:)
    @NSManaged public func removeFromRecommendations(at indexes: NSIndexSet)

    @objc(replaceObjectInRecommendationsAtIndex:withObject:)
    @NSManaged public func replaceRecommendations(at idx: Int, with value: CDRecommendation)

    @objc(replaceRecommendationsAtIndexes:withRecommendations:)
    @NSManaged public func replaceRecommendations(at indexes: NSIndexSet, with values: [CDRecommendation])

    @objc(addRecommendationsObject:)
    @NSManaged public func addToRecommendations(_ value: CDRecommendation)

    @objc(removeRecommendationsObject:)
    @NSManaged public func removeFromRecommendations(_ value: CDRecommendation)

    @objc(addRecommendations:)
    @NSManaged public func addToRecommendations(_ values: NSOrderedSet)

    @objc(removeRecommendations:)
    @NSManaged public func removeFromRecommendations(_ values: NSOrderedSet)
}
