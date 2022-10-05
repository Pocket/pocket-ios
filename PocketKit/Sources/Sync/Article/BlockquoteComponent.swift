import PocketGraph

public struct BlockquoteComponent: Codable, Equatable, Hashable {
    public let content: Markdown
}

extension BlockquoteComponent {
    init(_ marticle: MarticleBlockquoteParts) {
        self.init(content: marticle.content)
    }
}
