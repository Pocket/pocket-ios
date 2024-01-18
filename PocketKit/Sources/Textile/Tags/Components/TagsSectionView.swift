// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization

public struct TagsSectionView: View {
    @Environment(\.editMode)
    var editMode
    let recentTags: [TagType]
    let allTags: [TagType]
    let tagAction: (TagType) -> Void

    public init(recentTags: [TagType], allTags: [TagType], tagAction: @escaping (TagType) -> Void) {
        self.recentTags = recentTags
        self.allTags = allTags
        self.tagAction = tagAction
    }

    public var body: some View {
        Group {
            if editMode?.wrappedValue == .inactive, !recentTags.isEmpty {
                Section(header: Text(Localization.Tags.Section.recentTags).style(.tags.sectionHeader)) {
                    ForEach(recentTags, id: \.self) { tag in
                        TagsCell(tag: tag, tagAction: tagAction)
                    }
                }
            }
            Section(header: Text(Localization.Tags.Section.userTags).style(.tags.sectionHeader)) {
                ForEach(allTags, id: \.self) { tag in
                    TagsCell(tag: tag, tagAction: tagAction)
                }
            }
            .accessibilityIdentifier("all-tags-section")
        }
    }
}
