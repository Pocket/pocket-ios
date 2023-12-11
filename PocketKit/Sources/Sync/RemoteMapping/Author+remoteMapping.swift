// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import PocketGraph

extension Author {
    convenience init(remote: ItemParts.Author, context: NSManagedObjectContext) {
        self.init(context: context)

        id = remote.id
        name = remote.name
        url = remote.url.flatMap(URL.init(string:))
    }

    convenience init(remote: ItemSummary.Author, context: NSManagedObjectContext) {
        self.init(context: context)

        id = remote.id
        name = remote.name
        url = remote.url.flatMap(URL.init(string:))
    }
}
