import SwiftUI

struct ItemTags: View {
    var tags: [NSAttributedString]?
    var tagCount: NSAttributedString?

    let constants = ListItem.Constants.tags.self

    var body: some View {
        if let tags = tags {
            ForEach(tags.prefix(2), id: \.self) { tag in
                TagComponent(tag: tag)
            }
        }

        if let tagCount = tagCount {
            Text(tagCount.string)
                .style(.listItem.tagCount)
                .lineLimit(constants.maxLines)
        }
    }
}
