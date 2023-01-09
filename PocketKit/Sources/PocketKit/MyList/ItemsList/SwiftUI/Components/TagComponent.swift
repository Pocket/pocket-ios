import SwiftUI

struct TagComponent: View {
    var tag: NSAttributedString

    let constants = ListItem.Constants.tags.self

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(asset: .tag)
                .tagIconStyle()
            Text(tag.string.lowercased())
                .style(.listItem.tag)
                .lineLimit(constants.maxLines)
        }
        .tagBodyStyle()
        .accessibilityIdentifier("Article tag \(tag.string)")
    }
}
