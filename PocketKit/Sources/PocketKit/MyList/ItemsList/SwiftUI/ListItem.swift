import SwiftUI
import Textile
import Kingfisher

struct ListItem: View {
    var model: ItemsListItemCell.Model

    let constants = Constants.self

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                ItemDetails(attributedTitle: model.attributedTitle, attributedDetail: model.attributedDetail)

                KFImage(model.thumbnailURL)
                    .frame(width: constants.image.width, height: constants.image.height, alignment: .trailing)
                    .cornerRadius(constants.image.cornerRadius)
            }

            HStack(alignment: .center, spacing: constants.tags.horizontalSpacing) {
                ItemTags(tags: model.attributedTags, tagCount: model.attributedTagCount)

                Spacer()

                ActionButton(model.favoriteAction)

                ActionButton(model.shareAction)

                OverflowMenu(overflowActions: model.overflowActions, trackOverflow: model.swiftUITrackOverflow, trailingPadding: false)
            }
        }
        .padding(.vertical, constants.verticalPadding)
    }
}
