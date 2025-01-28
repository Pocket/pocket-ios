// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import PocketGraph
import SharedPocketKit

extension CDNote {
    public typealias NoteEdge = NotesQuery.Data.Notes.Edge

    // TODO: NOTES - The space argument will be used when we fetch relationships
    public func update(from noteEdge: NoteEdge, with space: Space) {
        self.title = noteEdge.node?.title
        self.contentPreview = noteEdge.node?.contentPreview
        self.body = noteEdge.node?.docMarkdown
        if let createdAt = noteEdge.node?.createdAt,
            let date = ISO8601DateFormatter.rfc3339WithFractionalSeconds.date(from: createdAt) {
            self.createdAt = date
        } else {
            self.createdAt = Date()
        }
        if let updatedAt = noteEdge.node?.updatedAt {
            self.updatedAt = ISO8601DateFormatter.rfc3339WithFractionalSeconds.date(from: updatedAt)
        }
        self.sourceUrl = noteEdge.node?.source
        self.archived = noteEdge.node?.archived ?? false
        // TODO: NOTES - Add logic to update related Saved Item when we roll it out (or earlier)
    }
}
