// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class CollectionStory {
    var excerpt: String
    var imageUrl: String?
    var publisher: String?
    var sortOrder: Int32? = 0
    var title: String
    var url: String
    var authors: [CollectionAuthor]
    var collection: Sync.Collection?
    var item: Item?
    public init(excerpt: String, title: String, url: String, authors: [CollectionAuthor] = []) {
        self.excerpt = excerpt
        self.title = title
        self.url = url
        self.authors = authors
    }

// #warning("The property \"ordered\" on CollectionStory:authors is unsupported in SwiftData.")
}
