// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

@objc(Collection)
public class Collection: NSManagedObject {
    @available(*, unavailable)
    public init() {
        fatalError()
    }

    @available(*, unavailable)
    public init(context: NSManagedObjectContext) {
        fatalError()
    }

    internal override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public init(
        context: NSManagedObjectContext,
        slug: String,
        title: String,
        authors: NSOrderedSet,
        stories: NSOrderedSet
    ) {
        let entity = NSEntityDescription.entity(forEntityName: "Collection", in: context)!
        super.init(entity: entity, insertInto: context)
        self.slug = slug
        self.title = title
        self.authors = authors
        self.stories = stories
    }
}
