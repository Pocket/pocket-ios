// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDSlateLineup {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDSlateLineup> {
        return NSFetchRequest<CDSlateLineup>(entityName: "SlateLineup")
    }

    @NSManaged public var experimentID: String
    @NSManaged public var remoteID: String
    @NSManaged public var requestID: String
    @NSManaged public var slates: NSOrderedSet?
}

// MARK: Generated accessors for slates
extension CDSlateLineup {
    @objc(insertObject:inSlatesAtIndex:)
    @NSManaged public func insertIntoSlates(_ value: CDSlate, at idx: Int)

    @objc(removeObjectFromSlatesAtIndex:)
    @NSManaged public func removeFromSlates(at idx: Int)

    @objc(insertSlates:atIndexes:)
    @NSManaged public func insertIntoSlates(_ values: [CDSlate], at indexes: NSIndexSet)

    @objc(removeSlatesAtIndexes:)
    @NSManaged public func removeFromSlates(at indexes: NSIndexSet)

    @objc(replaceObjectInSlatesAtIndex:withObject:)
    @NSManaged public func replaceSlates(at idx: Int, with value: CDSlate)

    @objc(replaceSlatesAtIndexes:withSlates:)
    @NSManaged public func replaceSlates(at indexes: NSIndexSet, with values: [CDSlate])

    @objc(addSlatesObject:)
    @NSManaged public func addToSlates(_ value: CDSlate)

    @objc(removeSlatesObject:)
    @NSManaged public func removeFromSlates(_ value: CDSlate)

    @objc(addSlates:)
    @NSManaged public func addToSlates(_ values: NSOrderedSet)

    @objc(removeSlates:)
    @NSManaged public func removeFromSlates(_ values: NSOrderedSet)
}
