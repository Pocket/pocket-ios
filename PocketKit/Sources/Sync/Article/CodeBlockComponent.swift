// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketGraph

public struct CodeBlockComponent: Codable, Equatable, Hashable {
    public let language: Int?
    public let text: String

    public init(language: Int?, text: String) {
        self.language = language
        self.text = text
    }
}

extension CodeBlockComponent {
    init(_ marticle: MarticleCodeBlockParts) {
        self.init(
            language: marticle.language,
            text: marticle.text
        )
    }
}

extension CodeBlockComponent: Highlightable {
    public var content: String {
        text
    }
}
