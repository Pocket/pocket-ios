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
        .contentShape(Rectangle())
        .onTapGesture {
            tagAction(tag)
        }
    }
}

struct RecentTag: View {
    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(asset: .tag)
                .tagIconStyle()
            Text("recent")
                .style(.tags.tag)
        }
        .accessibilityIdentifier("recent-tags")
    }
}

extension Image {
    func tagIconStyle() -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
                .frame(width: 13, height: 13)
                .foregroundColor(Color(.ui.grey4))
                .padding(.trailing, (8 - 2))
    }
}

struct TagsCell_PreviewProvider: PreviewProvider {
    static var previews: some View {
        let tagAction = { (tag: TagType) -> Void in
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

struct RecentTag_PreviewProvider: PreviewProvider {
    static var previews: some View {
        RecentTag()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Light")
            .preferredColorScheme(.light)

        RecentTag()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Dark")
            .preferredColorScheme(.dark)
    }
}
