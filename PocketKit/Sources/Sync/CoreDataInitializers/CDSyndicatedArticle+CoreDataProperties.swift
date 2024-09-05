// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDSyndicatedArticle {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDSyndicatedArticle> {
        return NSFetchRequest<CDSyndicatedArticle>(entityName: "SyndicatedArticle")
    }

    @NSManaged public var excerpt: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var itemID: String
    @NSManaged public var publisherName: String?
    @NSManaged public var title: String
    @NSManaged public var image: CDImage?
    @NSManaged public var item: CDItem?
}
