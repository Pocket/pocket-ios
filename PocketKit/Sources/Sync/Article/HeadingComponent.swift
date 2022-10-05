import PocketGraph

public struct HeadingComponent: MarkdownComponent, Codable, Equatable, Hashable {
    public let content: Markdown
    public let level: UInt
}

extension HeadingComponent {
    init(_ marticle: MarticleHeadingParts) {
        self.init(
            content: marticle.content,
            level: UInt(marticle.level)
        )
    }
}
