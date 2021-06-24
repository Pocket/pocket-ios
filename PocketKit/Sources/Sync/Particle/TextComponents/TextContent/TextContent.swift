// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct TextContent: Decodable, Hashable {
    public let text: String
    public let modifiers: [InlineModifier]?

    public init(text: String, modifiers: [InlineModifier]? = nil) {
        self.text = text
        self.modifiers = modifiers
    }
}
