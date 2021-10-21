public struct TextComponent: Codable, Equatable, Hashable {
    public let content: Markdown
}

extension TextComponent {
    init(_ marticle: MarticleTextParts) {
        self.init(content: marticle.content)
    }
}
