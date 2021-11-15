public protocol MarkdownListComponent {
    associatedtype Row: MarkdownListComponentRow
    var rows: [Row] { get }
}

public protocol MarkdownListComponentRow {
    var content: Markdown { get }
    var level: UInt { get }
    var prefix: String { get }
}
