// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Style {
    static let tags = TagsStyle()
    struct TagsStyle {
        let emptyStateText: Style = Style.header.sansSerif.p2.with { $0.with(alignment: .center).with(lineSpacing: 6) }
        public let sectionHeader: Style = Style.header.sansSerif.h8.with(color: .ui.grey4)
        public let tag: Style = Style.header.sansSerif.h8.with(color: .ui.grey4)
        let allTags: Style = Style.header.sansSerif.h8.with(color: .ui.grey1)
    }
}
