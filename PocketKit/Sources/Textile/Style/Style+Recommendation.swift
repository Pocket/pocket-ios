// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Style {
    static let recommendation = RecommendationStyle()
    struct RecommendationStyle {
        public let collection: Style = .header.sansSerif.p4
               .with(color: .ui.teal2)
               .with(weight: .bold)
               .with(maxScaleSize: 22)

        public let heroTitle: Style = .header.sansSerif.h6.with(color: .ui.black1).with { paragraph in
            paragraph.with(lineBreakMode: .byTruncatingTail).with(lineSpacing: 4)
        }

        public let title: Style = .header.sansSerif.h8.with(color: .ui.black1).with { paragraph in
            paragraph.with(lineSpacing: 4).with(lineBreakMode: .byTruncatingTail)
        }

        public let domain: Style = .header.sansSerif.p4.with(color: .ui.grey8).with(weight: .medium).with { paragraph in
            paragraph.with(lineBreakMode: .byTruncatingTail)
        }

        public let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey8).with { paragraph in
            paragraph.with(lineBreakMode: .byTruncatingTail)
        }.with(maxScaleSize: 22)
    }
}
