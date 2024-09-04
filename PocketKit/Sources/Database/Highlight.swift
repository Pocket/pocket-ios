// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
public class Highlight {
    var createdAt: Date
    var patch: String
    var quote: String
    var remoteID: String
    var updatedAt: Date
    var version: Int16 = 0
    var savedItem: SavedItem?
    public init(createdAt: Date, patch: String, quote: String, remoteID: String, updatedAt: Date) {
        self.createdAt = createdAt
        self.patch = patch
        self.quote = quote
        self.remoteID = remoteID
        self.updatedAt = updatedAt
    }
}
