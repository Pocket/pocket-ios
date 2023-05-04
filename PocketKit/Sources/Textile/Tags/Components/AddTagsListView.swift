// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

public struct TagsListView: View {
    let emptyStateText: String
    let recentTags: [TagType]
    let usersTags: [TagType]
    let tagAction: (TagType) -> Void

    public init(emptyStateText: String, recentTags: [TagType], usersTags: [TagType], tagAction: @escaping (TagType) -> Void) {
        self.emptyStateText = emptyStateText
        self.recentTags = recentTags
        self.usersTags = usersTags
        self.tagAction = tagAction
    }

    public var body: some View {
        if !usersTags.isEmpty {
            List {
                TagsSectionView(
                    showRecentTags: !recentTags.isEmpty,
                    recentTags: recentTags,
                    allTags: usersTags,
                    tagAction: tagAction
                )
            }
            .listStyle(.plain)
            .accessibilityIdentifier("all-tags")
        } else {
            TagsEmptyView(emptyStateText: emptyStateText)
        }
    }
}

struct TagsListView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        let tagAction = { (tag: TagType) -> Void in
            print("\(tag.name) action")
        }

        TagsListView(
            emptyStateText: "empty state text",
            recentTags: [TagType.recent("tag 0"), TagType.recent("tag 1"), TagType.recent("tag 2")],
            usersTags: [TagType.tag("tag 0"), TagType.tag("tag 1"), TagType.tag("tag 2")],
            tagAction: tagAction
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Light")
        .preferredColorScheme(.light)

        TagsListView(
            emptyStateText: "empty state text",
            recentTags: [TagType.recent("tag 0"), TagType.recent("tag 1"), TagType.recent("tag 2")],
            usersTags: [TagType.tag("tag 0"), TagType.tag("tag 1"), TagType.tag("tag 2")],
            tagAction: tagAction
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Dark")
        .preferredColorScheme(.dark)
    }
}
