// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct ContentEntity: Entity {
    public static let schema = "iglu:com.pocket/content/jsonschema/1-0-0"

    let url: URL
    let itemId: String?

    public init(url: URL, itemId: String? = nil) {
        self.url = url
        self.itemId = itemId
    }
}
