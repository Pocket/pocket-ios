// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketGraph

public struct HeadingComponent: MarkdownComponent, Codable, Equatable, Hashable {
    public let content: Markdown
    public let level: UInt

    public init(content: Markdown, level: UInt) {
        self.content = content
        self.level = level
    }
}

extension HeadingComponent {
    init(_ marticle: MarticleHeadingParts) {
        self.init(
            content: marticle.content,
            level: UInt(marticle.level)
        )
    }
}
