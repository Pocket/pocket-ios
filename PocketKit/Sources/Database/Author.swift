// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import Foundation

@available(iOS 17, *)
@Model
class Author {
    var id: String
    var name: String
    var url: URL

    init(id: String, name: String, url: URL) {
        self.id = id
        self.name = name
        self.url = url
    }
}
