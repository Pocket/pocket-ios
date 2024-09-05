// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDSharedWithYouItem {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDSharedWithYouItem> {
        return NSFetchRequest<CDSharedWithYouItem>(entityName: "SharedWithYouItem")
    }

    @NSManaged public var url: String
    @NSManaged public var sortOrder: Int32
    @NSManaged public var item: CDItem
}
