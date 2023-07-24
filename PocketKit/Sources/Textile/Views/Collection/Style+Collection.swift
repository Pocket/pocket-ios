// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Style {
    static let collection = CollectionStyle()
    struct CollectionStyle {
        public let title: Style = .header
            .serif
            .title
            .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
                paragraph.with(lineHeight: .multiplier(0.925))
            }

        public let authors: Style = .header.sansSerif.p4
            .with(color: .ui.black1)
            .with(weight: .medium)

        public let detail: Style = .header.sansSerif.p4
            .with(color: .ui.black1)

        public let excerpt: Style = .header.serif.p1
            .with(weight: .regular)
            .with(color: .ui.black1)

        public let intro: Style = .header.serif.p1
            .with(color: .ui.black1)

        public let collection: Style = .header.sansSerif.p4
            .with(color: .ui.teal2)
            .with(weight: .bold)
    }
}
