// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData


extension Recommendation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recommendation> {
        return NSFetchRequest<Recommendation>(entityName: "Recommendation")
    }

    @NSManaged public var excerpt: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var remoteID: String
    @NSManaged public var title: String?
    @NSManaged public var item: Item
    @NSManaged public var slate: Slate

}
