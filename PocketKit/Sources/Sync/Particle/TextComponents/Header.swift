// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct Header: Decodable, Hashable {
    public let level: Int
    public let text: TextContent

    public init(level: Int, text: TextContent) {
        self.level = level
        self.text = text
    }
}
