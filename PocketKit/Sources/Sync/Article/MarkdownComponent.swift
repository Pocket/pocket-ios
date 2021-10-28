public protocol MarkdownComponent {
    var content: Markdown { get }
}

public extension MarkdownComponent {
    var isEmpty: Bool { content.isEmpty }
}
