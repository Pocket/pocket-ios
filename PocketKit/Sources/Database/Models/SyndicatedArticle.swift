// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
public class SyndicatedArticle {
    // ios 18 only - #Unique<SyndicatedArticle>([\.itemID])
    var excerpt: String?
    var imageURL: URL?
    var itemID: String
    var publisherName: String?
    var title: String
    var image: Image?
    var item: Item?
    public init(itemID: String, title: String) {
        self.itemID = itemID
        self.title = title
    }
}
