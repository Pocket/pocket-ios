// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import PocketGraph

extension CDImage {
    convenience init(remote: ItemParts.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }

    convenience init(remote: CompactItem.Image, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: remote.src)
    }

    convenience init(src: String, context: NSManagedObjectContext) {
        self.init(context: context)

        source = URL(string: src)
    }

    convenience init(url: URL, context: NSManagedObjectContext) {
        self.init(context: context)

        source = url
    }
}
