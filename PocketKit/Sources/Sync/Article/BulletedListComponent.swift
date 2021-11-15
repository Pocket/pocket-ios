public struct BulletedListComponent: MarkdownListComponent, Codable, Equatable, Hashable {
    public let rows: [Row]

    public struct Row: MarkdownListComponentRow, Codable, Equatable, Hashable {
        public let content: Markdown
        public let level: UInt
        
        public var prefix: String {
            switch level {
            case 0:
                return "\u{2022} "
            case 1:
                return "\u{25e6} "
            default:
                return "\u{25AA}\u{fe0e} "
            }
        }
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
