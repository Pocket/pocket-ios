// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension Image {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var isDownloaded: Bool
    @NSManaged public var source: URL?
    @NSManaged public var item: Item?
    @NSManaged public var recommendation: Recommendation?
    @NSManaged public var syndicatedArticle: SyndicatedArticle?
}
