// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Note {
    var noteID: UUID
    var createdAt: Date
    var updatedAt: Date?
    var sourceUrl: String?
    var title: String?
    var contentPreview: String?
    var body: String?
    var savedItem: SavedItem?
    var image: Image?
    public init(createdAt: Date, noteID: UUID) {
        self.createdAt = createdAt
        self.noteID = noteID
    }
}
