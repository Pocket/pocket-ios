// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketGraph

public struct BulletedListComponent: Codable, Equatable, Hashable {
    public let rows: [Row]

    public struct Row: Codable, Equatable, Hashable {
        public let content: Markdown
        public let level: UInt

        public init(content: Markdown, level: UInt) {
            self.content = content
            self.level = level
        }
    }

    public init(rows: [Row]) {
        self.rows = rows
    }
}

extension BulletedListComponent {
    init(_ marticle: MarticleBulletedListParts) {
        self.init(rows: marticle.rows.map(BulletedListComponent.Row.init))
    }
}

extension BulletedListComponent: Highlightable {
    public var content: String {
        rows.map { $0.content }.joined(separator: "\n")
    }
}

extension BulletedListComponent.Row {
    init(_ marticle: MarticleBulletedListParts.Row) {
        self.init(
            content: marticle.content,
            level: UInt(marticle.level)
        )
    }
}
