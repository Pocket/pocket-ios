// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

@objc(Highlight)
public class Highlight: NSManagedObject {
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
        remoteID: String,
        createdAt: Date,
        updatedAt: Date,
        patch: String,
        quote: String,
        version: Int16
    ) {
        let entity = NSEntityDescription.entity(forEntityName: "Highlight", in: context)!
        super.init(entity: entity, insertInto: context)
        self.remoteID = remoteID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.patch = patch
        self.quote = quote
        self.version = version
    }
}
