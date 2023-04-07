// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct TagsListView: View {
    let sectionTitle: String
    let emptyStateText: String
    let usersTags: [TagType]
    let tagAction: (TagType) -> Void

    var body: some View {
        if !usersTags.isEmpty {
            List {
                Section(header: Text(sectionTitle).style(.tags.sectionHeader)) {
                    ForEach(usersTags, id: \.self) { tag in
                        TagsCell(tag: tag, tagAction: tagAction)
                    }
                }
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
            sectionTitle: "tag section title",
            emptyStateText: "empty state text",
            usersTags: [TagType.tag("tag 0"), TagType.tag("tag 1"), TagType.tag("tag 2")],
            tagAction: tagAction
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Light")
        .preferredColorScheme(.light)

        TagsListView(
            sectionTitle: "tag section title",
            emptyStateText: "empty state text",
            usersTags: [TagType.tag("tag 0"), TagType.tag("tag 1"), TagType.tag("tag 2")],
            tagAction: tagAction
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Dark")
        .preferredColorScheme(.dark)
    }
}
