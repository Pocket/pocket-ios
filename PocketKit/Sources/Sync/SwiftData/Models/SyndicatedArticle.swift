// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class SyndicatedArticle {
    // #Unique<SyndicatedArticle>([\.itemID])
    public var excerpt: String?
    public var imageURL: URL?
    public var itemID: String
    public var publisherName: String?
    public var title: String
    public var image: Image?
    public var item: Item?
    public init(itemID: String, title: String) {
        self.itemID = itemID
        self.title = title
    }
}
