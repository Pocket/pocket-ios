public struct HeadingComponent: MarkdownComponent, Codable, Equatable, Hashable {
    private let _content: Markdown
    public let level: UInt

    public var content: Markdown {
        return [
            String(repeating: "#", count: Int(level)),
            _content
        ].joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case _content = "content"
        case level
    }

    init(content: String, level: UInt) {
        self._content = content
        self.level = level
    }
}

extension HeadingComponent {
    init(_ marticle: MarticleHeadingParts) {
        self.init(
            content: marticle.content,
            level: UInt(marticle.level)
        )
    }
}
