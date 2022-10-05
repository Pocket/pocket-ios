import PocketGraph

public struct CodeBlockComponent: Codable, Equatable, Hashable {
    public let language: Int?
    public let text: String
}

extension CodeBlockComponent {
    init(_ marticle: MarticleCodeBlockParts) {
        self.init(
            language: marticle.language,
            text: marticle.text
        )
    }
}
