// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Image {
    public var isDownloaded: Bool? = false
    public var source: URL?
    @Relationship(inverse: \Item.images)
    public var item: Item?
    @Relationship(inverse: \Recommendation.image)
    public var recommendation: Recommendation?
    @Relationship(inverse: \SyndicatedArticle.image)
    public var syndicatedArticle: SyndicatedArticle?
    public init() {
    }
}
