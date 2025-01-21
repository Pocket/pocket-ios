// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Note {
    public var noteID: String
    public var createdAt: Date
    public var updatedAt: Date?
    public var sourceUrl: String?
    public var title: String?
    public var contentPreview: String?
    public var body: String?
    public var archived: Bool = false
    public var savedItem: SavedItem?
    public var image: Image?
    public init(createdAt: Date, noteID: String) {
        self.createdAt = createdAt
        self.noteID = noteID
    }
}
