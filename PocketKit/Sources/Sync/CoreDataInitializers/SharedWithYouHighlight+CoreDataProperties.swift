// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension SharedWithYouHighlight {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<SharedWithYouHighlight> {
        return NSFetchRequest<SharedWithYouHighlight>(entityName: "SharedWithYouHighlight")
    }

    @NSManaged public var sortOrder: Int32
    @NSManaged public var url: URL
    @NSManaged public var item: Item
}
