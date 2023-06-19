// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension Annotations {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Annotations> {
        return NSFetchRequest<Annotations>(entityName: "Annotations")
    }

    @NSManaged public var highlights: NSSet?
    @NSManaged public var savedItem: SavedItem?
}

// MARK: Generated accessors for highlights
extension Annotations {
    @objc(addHighlightsObject:)
    @NSManaged public func addToHighlights(_ value: Highlight)

    @objc(removeHighlightsObject:)
    @NSManaged public func removeFromHighlights(_ value: Highlight)

    @objc(addHighlights:)
    @NSManaged public func addToHighlights(_ values: NSSet)

    @objc(removeHighlights:)
    @NSManaged public func removeFromHighlights(_ values: NSSet)
}
