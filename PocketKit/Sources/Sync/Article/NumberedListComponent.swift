import PocketGraph

public struct NumberedListComponent: Codable, Equatable, Hashable {
    public let rows: [Row]

    public struct Row: Codable, Equatable, Hashable {
        public let content: Markdown
        public let level: UInt
        public let index: UInt
    }
}

extension NumberedListComponent {
    init(_ marticle: MarticleNumberedListParts) {
        self.init(rows: marticle.rows.map(NumberedListComponent.Row.init))
    }
}

extension NumberedListComponent.Row {
    init(_ marticle: MarticleNumberedListParts.Row) {
        self.init(
            content: marticle.content,
            level: UInt(marticle.level),
            index: UInt(marticle.index)
        )
    }
}
