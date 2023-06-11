// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension SyndicatedArticle {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<SyndicatedArticle> {
        return NSFetchRequest<SyndicatedArticle>(entityName: "SyndicatedArticle")
    }

    @NSManaged public var excerpt: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var itemID: String
    @NSManaged public var publisherName: String?
    @NSManaged public var title: String
    @NSManaged public var image: Image?
    @NSManaged public var item: Item?
}
