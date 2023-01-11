import SwiftUI
import Textile
import Kingfisher

struct ListItem: View {
    var model: SearchItem

    let constants = Constants.self

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                ItemDetails(attributedTitle: model.title, attributedDetail: model.detail)

                KFImage(model.thumbnailURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: constants.image.width, height: constants.image.height, alignment: .center)
                    .cornerRadius(constants.image.cornerRadius)
            }

            HStack(alignment: .center, spacing: constants.tags.horizontalSpacing) {
                ItemTags(tags: model.tags, tagCount: model.tagCount)
                Spacer()
                ActionButton(model.favoriteAction)
                ActionButton(model.shareAction)
                OverflowMenu(overflowActions: model.overflowActions, trackOverflow: model.trackOverflow, trailingPadding: false)
            }
        }
        .padding(.vertical, constants.verticalPadding)
    }
}
