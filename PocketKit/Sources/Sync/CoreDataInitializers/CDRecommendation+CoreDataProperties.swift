// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension CDRecommendation {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDRecommendation> {
        return NSFetchRequest<CDRecommendation>(entityName: "Recommendation")
    }

    @NSManaged public var excerpt: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var remoteID: String
    @NSManaged public var title: String?
    @NSManaged public var analyticsID: String
    @NSManaged public var item: CDItem
    @NSManaged public var slate: Slate?
    @NSManaged public var image: CDImage?
    @NSManaged public var sortIndex: NSNumber?
}

extension CDRecommendation {
    /// The slug of the associated collection
    public var collectionSlug: String? {
        item.collection?.slug
    }

    public var collection: CDCollection? {
        item.collection
    }
}
