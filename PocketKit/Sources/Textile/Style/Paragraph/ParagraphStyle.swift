// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
