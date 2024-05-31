// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI

public struct Style: Sendable {
    let fontDescriptor: FontDescriptor
    let maxScaleSize: CGFloat?
    let colorAsset: ColorAsset
    let underlineStyle: UnderlineStyle
    let strike: Strike
    let backgroundColorAsset: ColorAsset?
    public let paragraph: ParagraphStyle

    init(
        fontDescriptor: FontDescriptor,
        maxScaleSize: CGFloat? = nil,
        color: ColorAsset = .ui.grey1,
        underlineStyle: UnderlineStyle = .none,
        strike: Strike = .none,
        paragraph: ParagraphStyle = ParagraphStyle(alignment: .left),
        backgroundColor: ColorAsset? = nil
    ) {
        self.fontDescriptor = fontDescriptor
        self.maxScaleSize = maxScaleSize
        self.colorAsset = color
        self.underlineStyle = underlineStyle
        self.strike = strike
        self.paragraph = paragraph
        self.backgroundColorAsset = backgroundColor
    }

    init(
        family: FontDescriptor.Family = .graphik,
        size: FontDescriptor.Size = .body,
        weight: FontDescriptor.Weight = .regular,
        color: ColorAsset = .ui.grey1,
        underlineStyle: UnderlineStyle = .none,
        strike: Strike = .none,
        paragraph: ParagraphStyle = ParagraphStyle(alignment: .left),
        backgroundColor: ColorAsset? = nil
    ) {
        self.init(
            fontDescriptor: FontDescriptor(
                family: family,
                size: size,
                weight: weight
            ),
            color: color,
            underlineStyle: underlineStyle,
            strike: strike,
            backgroundColor: backgroundColor
        )
    }

    public func with(size: FontDescriptor.Size) -> Style {
        Style(
            fontDescriptor: fontDescriptor.with(size: size),
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(maxScaleSize: CGFloat) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            maxScaleSize: maxScaleSize,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(family: FontDescriptor.Family) -> Style {
        Style(
            fontDescriptor: fontDescriptor.with(family: family),
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(weight: FontDescriptor.Weight) -> Style {
        Style(
            fontDescriptor: fontDescriptor.with(weight: weight),
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(slant: FontDescriptor.Slant) -> Style {
        Style(
            fontDescriptor: fontDescriptor.with(slant: slant),
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(color: ColorAsset) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: color,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(underlineStyle: UnderlineStyle) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(strike: Strike) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(buildParagraph: (ParagraphStyle) -> ParagraphStyle) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: buildParagraph(paragraph),
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(backgroundColor: ColorAsset?) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColor
        )
    }

    public func adjustingSize(by adjustment: Int) -> Style {
        Style(
            fontDescriptor: fontDescriptor.adjustingSize(by: adjustment),
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph,
            backgroundColor: backgroundColorAsset
        )
    }

    public func scalingLineHeight(by factor: CGFloat) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph.scaleLineHeight(by: factor),
            backgroundColor: backgroundColorAsset
        )
    }

    public func with(alignment: TextAlignment) -> Style {
        Style(
            fontDescriptor: fontDescriptor,
            color: colorAsset,
            underlineStyle: underlineStyle,
            strike: strike,
            paragraph: paragraph.with(alignment: alignment),
            backgroundColor: backgroundColorAsset
        )
    }
}
