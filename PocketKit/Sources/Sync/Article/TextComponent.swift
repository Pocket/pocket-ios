// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketGraph

public struct TextComponent: MarkdownComponent, Codable, Equatable, Hashable {
    public let content: Markdown

    public init(content: Markdown) {
        self.content = content
    }
}

extension TextComponent {
    init(_ marticle: MarticleTextParts) {
        self.init(content: marticle.content)
    }
}
