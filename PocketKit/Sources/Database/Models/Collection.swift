// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
public class Collection {
    // ios 18 only - #Unique<Collection>([\.slug])
    var intro: String?
    var publishedAt: Date?
    var slug: String
    var title: String
    var authors: [CollectionAuthor]
    @Relationship(inverse: \Item.collection)
    var item: Item?
    @Relationship(inverse: \CollectionStory.collection)
    var stories: [CollectionStory]
    public init(slug: String, title: String, authors: [CollectionAuthor] = [], stories: [CollectionStory] = []) {
        self.slug = slug
        self.title = title
        self.authors = authors
        self.stories = stories
    }

#warning("The property \"ordered\" on Collection:authors is unsupported in SwiftData.")
#warning("The property \"ordered\" on Collection:stories is unsupported in SwiftData.")
}
