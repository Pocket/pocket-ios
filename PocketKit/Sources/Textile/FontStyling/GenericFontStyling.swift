// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// Concrete implementation of FontStyling for premium fonts
public struct PremiumFontOSFStyling: FontStyling {
    public let h1: Style
    public let h2: Style
    public let h3: Style
    public let h4: Style
    public let h5: Style
    public let h6: Style
    public let body: Style
    public let monospace: Style

    public init(
        h1: Style,
        h2: Style,
        h3: Style,
        h4: Style,
        h5: Style,
        h6: Style,
        body: Style,
        monospace: Style
    ) {
        self.h1 = h1
        self.h2 = h2
        self.h3 = h3
        self.h4 = h4
        self.h5 = h5
        self.h6 = h6
        self.body = body
        self.monospace = monospace
    }

    public init(family: FontDescriptor.Family) {
        let headerStyles = Style.header.headerStyles(with: family)
        self.init(
            h1: headerStyles.h1.with{ (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.97))
            },
            h2: headerStyles.h2.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.95))
            },
            h3: headerStyles.h3.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.95))
            },
            h4: headerStyles.h4.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.96))
            },
            h5: headerStyles.h5.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.89))
            },
            h6: headerStyles.h6.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.9))
            },
            body: .body.bodyStyle(with: family).with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(1.1))
            },
            monospace: .body.monospace)
    }

    public func bolding(style: Style) -> Style {
        style.with(weight: .semibold)
    }

    public func with(body: Style) -> FontStyling {
        PremiumFontOSFStyling(
            h1: h1,
            h2: h2,
            h3: h3,
            h4: h4,
            h5: h5,
            h6: h6,
            body: body,
            monospace: monospace
        )
    }
}

