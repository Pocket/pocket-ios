// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class CollectionStory {
    public var excerpt: String
    public var imageUrl: String?
    public var publisher: String?
    public var sortOrder: Int32? = 0
    public var title: String
    public var url: String
    public var authors: [CollectionAuthor]
    public var collection: Sync.Collection?
    public var item: Item?
    public init(excerpt: String, title: String, url: String, authors: [CollectionAuthor] = []) {
        self.excerpt = excerpt
        self.title = title
        self.url = url
        self.authors = authors
    }

// #warning("The property \"ordered\" on CollectionStory:authors is unsupported in SwiftData.")
}
