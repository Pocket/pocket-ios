// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct NoteListPresenter {
    let title: String?
    let content: String
    let createdAt: String
    let updatedAt: String?
    let sourceUrl: String?

    init() {
        self.title = nil
        self.content = ""
        self.createdAt = ""
        self.updatedAt = nil
        self.sourceUrl = nil
    }

    init(
        title: String?,
        content: String,
        createdAt: String,
        updatedAt: String?,
        sourceUrl: String?
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sourceUrl = sourceUrl
    }
}
