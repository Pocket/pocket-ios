// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class CollectionAuthor {
    // ios 18 only - #Unique<CollectionAuthor>([\.name])
    var name: String
    @Relationship(inverse: \Collection.authors)
    var collection: [Collection]?
    @Relationship(inverse: \CollectionStory.authors)
    var collectionStory: [CollectionStory]?
    public init(name: String) {
        self.name = name
    }
}
