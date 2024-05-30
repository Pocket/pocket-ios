// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import SwiftUI

public struct TagsCell: View {
    let tag: TagType
    let tagAction: (TagType) -> Void

    public init(tag: TagType, tagAction: @escaping (TagType) -> Void) {
        self.tag = tag
        self.tagAction = tagAction
    }

    public var body: some View {
        HStack {
            Text(tag.name)
                .style(.tags.allTags)
                .accessibilityIdentifier("all-tags")
            Spacer()
            if case .recent = tag {
                RecentTag()
            }
        }
        .id(tag.name)
        .contentShape(Rectangle())
        .onTapGesture {
            tagAction(tag)
        }
    }
}

struct TagsCell_PreviewProvider: PreviewProvider {
    static var previews: some View {
        let tagAction = { (tag: TagType) in
            print("\(tag.name) action")
        }

        TagsCell(tag: TagType.tag("test tag"), tagAction: tagAction)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Light")
            .preferredColorScheme(.light)

        TagsCell(tag: TagType.tag("test tag"), tagAction: tagAction)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)

        TagsCell(tag: TagType.recent("test tag"), tagAction: tagAction)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Recent Tag - Light")
            .preferredColorScheme(.light)

        TagsCell(tag: TagType.recent("test tag"), tagAction: tagAction)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Recent Tag - Dark")
            .preferredColorScheme(.dark)
    }
}
