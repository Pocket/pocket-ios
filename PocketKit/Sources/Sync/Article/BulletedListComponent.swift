import PocketGraph

public struct BulletedListComponent: Codable, Equatable, Hashable {
    public let rows: [Row]

    public struct Row: Codable, Equatable, Hashable {
        public let content: Markdown
        public let level: UInt
    }
}

extension BulletedListComponent {
    init(_ marticle: MarticleBulletedListParts) {
        self.init(rows: marticle.rows.map(BulletedListComponent.Row.init))
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
