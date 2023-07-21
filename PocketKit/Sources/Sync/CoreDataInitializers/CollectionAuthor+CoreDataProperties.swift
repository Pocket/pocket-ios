// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CollectionAuthor {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CollectionAuthor> {
        return NSFetchRequest<CollectionAuthor>(entityName: "CollectionAuthor")
    }

    @NSManaged public var name: String
    @NSManaged public var collection: Collection?
    @NSManaged public var collectionStory: CollectionStory?
}
