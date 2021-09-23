public enum LineBreakMode {
    case byTruncatingTail
    case none
}


public struct ParagraphStyle {
    public let alignment: TextAlignment
    public let lineBreakMode: LineBreakMode

    public init(alignment: TextAlignment, lineBreakMode: LineBreakMode = .none) {
        self.alignment = alignment
        self.lineBreakMode = lineBreakMode
    }

    public func with(alignment: TextAlignment) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode)
    }

    public func with(lineBreakMode: LineBreakMode) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode)
    }
}
