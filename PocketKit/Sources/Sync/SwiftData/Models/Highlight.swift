// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Highlight {
    public var createdAt: Date
    public var patch: String
    public var quote: String
    public var remoteID: String
    public var updatedAt: Date
    public var version: Int16 = 0
    @Relationship(inverse: \SavedItem.highlights)
    var savedItem: SavedItem?
    public init(createdAt: Date, patch: String, quote: String, remoteID: String, updatedAt: Date) {
        self.createdAt = createdAt
        self.patch = patch
        self.quote = quote
        self.remoteID = remoteID
        self.updatedAt = updatedAt
    }
}
