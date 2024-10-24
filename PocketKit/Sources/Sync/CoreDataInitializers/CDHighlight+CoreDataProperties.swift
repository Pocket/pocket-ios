// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDHighlight {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDHighlight> {
        return NSFetchRequest<CDHighlight>(entityName: "Highlight")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var patch: String
    @NSManaged public var quote: String
    @NSManaged public var updatedAt: Date
    @NSManaged public var version: Int16
    @NSManaged public var remoteID: String?
    @NSManaged public var savedItem: CDSavedItem?
}
