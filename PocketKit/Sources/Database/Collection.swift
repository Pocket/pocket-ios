// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import Foundation

@available(iOS 17, *)
@Model
class Collection {
    var intro: String
    var publishedAt: Date
    var slug: String
    var title: String

    init(intro: String, publishedAt: Date, slug: String, title: String) {
        self.intro = intro
        self.publishedAt = publishedAt
        self.slug = slug
        self.title = title
    }
}
