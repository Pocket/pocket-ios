// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization

public struct TagsSectionView: View {
    let recentTags: [TagType]
    let allTags: [TagType]
    let tagAction: (TagType) -> Void
    let showRecentTags: Bool

    public init(showRecentTags: Bool, recentTags: [TagType], allTags: [TagType], tagAction: @escaping (TagType) -> Void) {
        self.showRecentTags = showRecentTags
        self.recentTags = recentTags
        self.allTags = allTags
        self.tagAction = tagAction
    }

    public var body: some View {
        Group {
            if showRecentTags {
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

struct TagsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let tagAction = { (tag: TagType) in
            print("\(tag.name) action")
        }

        TagsSectionView(
            showRecentTags: true,
            recentTags: [TagType.recent("tag 0"), TagType.recent("tag 1"), TagType.recent("tag 2")],
            allTags: [TagType.tag("tag 0"), TagType.tag("tag 1"), TagType.tag("tag 2")],
            tagAction: tagAction
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Light")
        .preferredColorScheme(.light)

        TagsSectionView(
            showRecentTags: true,
            recentTags: [TagType.recent("tag 0"), TagType.recent("tag 1"), TagType.recent("tag 2")],
            allTags: [TagType.tag("tag 0"), TagType.tag("tag 1"), TagType.tag("tag 2")],
            tagAction: tagAction
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Dark")
        .preferredColorScheme(.dark)
    }
}
