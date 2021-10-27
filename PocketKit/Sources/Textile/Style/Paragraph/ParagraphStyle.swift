import CoreGraphics


public enum LineBreakMode {
    case byTruncatingTail
    case none
}

public struct ParagraphStyle {
    public let alignment: TextAlignment
    public let lineBreakMode: LineBreakMode
    public let lineSpacing: CGFloat?

    public init(
        alignment: TextAlignment,
        lineBreakMode: LineBreakMode = .none,
        lineSpacing: CGFloat? = nil
    ) {
        self.alignment = alignment
        self.lineBreakMode = lineBreakMode
        self.lineSpacing = lineSpacing
    }

    public func with(alignment: TextAlignment) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing)
    }

    public func with(lineBreakMode: LineBreakMode) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing)
    }

    public func with(lineSpacing: CGFloat?) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing)
    }
}
