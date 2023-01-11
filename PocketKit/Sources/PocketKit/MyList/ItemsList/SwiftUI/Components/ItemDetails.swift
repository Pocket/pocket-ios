import SwiftUI

struct ItemDetails: View {
    private let constants = ListItem.Constants.self
    private let title: String
    private let detail: String

    init(attributedTitle: NSAttributedString, attributedDetail: NSAttributedString) {
        self.title = attributedTitle.string
        self.detail = attributedDetail.string
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .style(.listItem.title)
                .lineLimit(constants.title.maxLines)
                .lineSpacing(constants.title.lineSpacing)
                .padding(.bottom, constants.title.padding)
            Text(detail)
                .style(.listItem.detail)
                .lineLimit(constants.detail.maxLines)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding([.bottom, .trailing], constants.objectSpacing)
    }
}
