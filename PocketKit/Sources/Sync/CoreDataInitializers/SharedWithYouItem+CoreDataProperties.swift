// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData


extension SharedWithYouItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SharedWithYouItem> {
        return NSFetchRequest<SharedWithYouItem>(entityName: "SharedWithYouItem")
    }

    @NSManaged public var url: String?
    @NSManaged public var sortOrder: Int32
    @NSManaged public var item: Item?

}
