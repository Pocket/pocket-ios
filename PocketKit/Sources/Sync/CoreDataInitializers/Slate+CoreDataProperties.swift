// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData


extension Slate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Slate> {
        return NSFetchRequest<Slate>(entityName: "Slate")
    }

    @NSManaged public var experimentID: String
    @NSManaged public var name: String?
    @NSManaged public var remoteID: String
    @NSManaged public var requestID: String
    @NSManaged public var slateDescription: String?
    @NSManaged public var recommendations: NSOrderedSet
    @NSManaged public var slateLineup: SlateLineup

}

// MARK: Generated accessors for recommendations
extension Slate {

    @objc(insertObject:inRecommendationsAtIndex:)
    @NSManaged public func insertIntoRecommendations(_ value: Recommendation, at idx: Int)

    @objc(removeObjectFromRecommendationsAtIndex:)
    @NSManaged public func removeFromRecommendations(at idx: Int)

    @objc(insertRecommendations:atIndexes:)
    @NSManaged public func insertIntoRecommendations(_ values: [Recommendation], at indexes: NSIndexSet)

    @objc(removeRecommendationsAtIndexes:)
    @NSManaged public func removeFromRecommendations(at indexes: NSIndexSet)

    @objc(replaceObjectInRecommendationsAtIndex:withObject:)
    @NSManaged public func replaceRecommendations(at idx: Int, with value: Recommendation)

    @objc(replaceRecommendationsAtIndexes:withRecommendations:)
    @NSManaged public func replaceRecommendations(at indexes: NSIndexSet, with values: [Recommendation])

    @objc(addRecommendationsObject:)
    @NSManaged public func addToRecommendations(_ value: Recommendation)

    @objc(removeRecommendationsObject:)
    @NSManaged public func removeFromRecommendations(_ value: Recommendation)

    @objc(addRecommendations:)
    @NSManaged public func addToRecommendations(_ values: NSOrderedSet)

    @objc(removeRecommendations:)
    @NSManaged public func removeFromRecommendations(_ values: NSOrderedSet)

}
