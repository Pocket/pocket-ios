// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct GraphikLCGStyling: FontStyling {
    public let h1: Style
    public let h2: Style
    public let h3: Style
    public let h4: Style
    public let h5: Style
    public let h6: Style
    public let body: Style
    public let monospace: Style

    public init(
        h1: Style = Self.defaultH1,
        h2: Style = Self.defaultH2,
        h3: Style = Self.defaultH3,
        h4: Style = Self.defaultH4,
        h5: Style = Self.defaultH5,
        h6: Style = Self.defaultH6,
        body: Style = Self.defaultBody,
        monospace: Style = Self.defaultMonospace
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

    public func bolding(style: Style) -> Style {
        style.with(weight: .medium)
    }

    public func with(body: Style) -> FontStyling {
        GraphikLCGStyling(
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

public extension GraphikLCGStyling {
    static let defaultH1: Style = .header.sansSerif.h1.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(0.97))
    }

    static let defaultH2: Style = .header.sansSerif.h2.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(0.95))
    }

    static let defaultH3: Style = .header.sansSerif.h3.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(0.95))
    }

    static let defaultH4: Style = .header.sansSerif.h4.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(0.96))
    }

    static let defaultH5: Style = .header.sansSerif.h5.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(0.89))
    }

    static let defaultH6: Style = .header.sansSerif.h6.with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(0.9))
    }

    static let defaultBody: Style = .body.sansSerif.with(size: .body.adjusting(by: -3)).with { (paragraph: ParagraphStyle) -> ParagraphStyle in
        paragraph.with(lineHeight: .multiplier(1.2))
    }

    static let defaultMonospace: Style = .body.monospace
}
