// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Image {
    var isDownloaded: Bool? = false
    var source: URL?
    @Relationship(inverse: \Item.images)
    var item: Item?
    @Relationship(inverse: \Recommendation.image)
    var recommendation: Recommendation?
    @Relationship(inverse: \SyndicatedArticle.image)
    var syndicatedArticle: SyndicatedArticle?
    public init() {
    }
}
