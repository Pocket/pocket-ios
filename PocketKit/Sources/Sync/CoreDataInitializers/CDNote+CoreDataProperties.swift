// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData


extension CDNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDNote> {
        return NSFetchRequest<CDNote>(entityName: "Note")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var sourceUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var contentPreview: String?
    @NSManaged public var content: String?
    @NSManaged public var savedItem: CDSavedItem?
    @NSManaged public var image: CDImage?

}
