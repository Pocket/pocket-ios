import SwiftUI
import Textile
import Kingfisher
import SharedPocketKit

struct ListItem: View {
    @ObservedObject
    var viewModel: PocketItemViewModel

    let scope: SearchScope

    let constants = Constants.self

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                ItemDetails(attributedTitle: viewModel.item.title, attributedDetail: viewModel.item.detail)

                KFImage(viewModel.item.thumbnailURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: constants.image.width, height: constants.image.height, alignment: .center)
                    .cornerRadius(constants.image.cornerRadius)
            }

            HStack(alignment: .center, spacing: constants.tags.horizontalSpacing) {
                ItemTags(tags: viewModel.item.tags, tagCount: viewModel.item.tagCount)
                Spacer()
                ActionButton(viewModel.favoriteAction(index: viewModel.index, scope: scope), selected: viewModel.isFavorite)
                ActionButton(viewModel.shareAction)
                OverflowMenu(overflowActions: viewModel.overflowActions, trackOverflow: viewModel.trackOverflow, trailingPadding: false)
            }
        }
        .padding(.vertical, constants.verticalPadding)
    }
}
