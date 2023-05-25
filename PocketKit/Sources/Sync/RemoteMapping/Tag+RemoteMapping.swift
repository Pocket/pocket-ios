// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import PocketGraph

extension Tag {
    typealias TagEdge = TagsQuery.Data.User.Tags.Edge
    func update(remote: TagParts) {
        remoteID = remote.id
        name = remote.name
    }
}
