import PocketGraph

public struct DividerComponent: Codable, Equatable, Hashable {
    public let content: Markdown
}

extension DividerComponent {
    init(_ marticle: MarticleDividerParts) {
        self.init(content: marticle.content)
    }
}
