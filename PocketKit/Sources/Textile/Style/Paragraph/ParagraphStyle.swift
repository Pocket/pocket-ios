// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreGraphics

public enum LineBreakMode: Sendable {
    case byTruncatingTail
    case none
}

public enum LineHeight: Sendable {
    case explicit(CGFloat)
    case multiplier(CGFloat)
}

public struct ParagraphStyle: Sendable {
    public let alignment: TextAlignment
    public let lineBreakMode: LineBreakMode
    public let lineSpacing: CGFloat?
    public let lineHeight: LineHeight?
    public let verticalAlignment: VerticalTextAlignment

    public init(
        alignment: TextAlignment,
        lineBreakMode: LineBreakMode = .none,
        lineSpacing: CGFloat? = nil,
        lineHeight: LineHeight? = nil,
        verticalAlignment: VerticalTextAlignment = .default
    ) {
        self.alignment = alignment
        self.lineBreakMode = lineBreakMode
        self.lineSpacing = lineSpacing
        self.lineHeight = lineHeight
        self.verticalAlignment = verticalAlignment
    }

    public func with(alignment: TextAlignment) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing, lineHeight: lineHeight, verticalAlignment: verticalAlignment)
    }

    public func with(lineBreakMode: LineBreakMode) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing, lineHeight: lineHeight, verticalAlignment: verticalAlignment)
    }

    public func with(lineSpacing: CGFloat?) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing, lineHeight: lineHeight, verticalAlignment: verticalAlignment)
    }

    public func with(lineHeight: LineHeight?) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing, lineHeight: lineHeight, verticalAlignment: verticalAlignment)
    }

    public func with(verticalAlignment: VerticalTextAlignment) -> ParagraphStyle {
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing, lineHeight: lineHeight, verticalAlignment: verticalAlignment)
    }

    public func scaleLineHeight(by factor: CGFloat) -> ParagraphStyle {
        let scaledLineHeight = scaledLineHeight(factor)
        return ParagraphStyle(alignment: alignment, lineBreakMode: lineBreakMode, lineSpacing: lineSpacing, lineHeight: scaledLineHeight, verticalAlignment: verticalAlignment)
    }

    func scaledLineHeight(_ factor: CGFloat) -> LineHeight? {
        switch lineHeight {
        case .explicit(let explicitValue):
            return .explicit(explicitValue * factor)
        case .multiplier(let multiplierValue):
            return .multiplier(multiplierValue * factor)
        case nil:
            return nil
        }
    }
}
