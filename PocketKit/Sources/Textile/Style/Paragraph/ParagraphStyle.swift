public struct ParagraphStyle {
    public let alignment: TextAlignment

    public init(alignment: TextAlignment) {
        self.alignment = alignment
    }

    public func with(alignment: TextAlignment) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment)
    }
}
