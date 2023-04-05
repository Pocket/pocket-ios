import SwiftUI
import Textile
import Kingfisher
import SharedPocketKit

struct ListItem: View {
    @ObservedObject var viewModel: PocketItemViewModel

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
                ActionButton(viewModel.favoriteAction(), selected: viewModel.isFavorite)
                ActionButton(viewModel.shareAction())
                    .sheet(isPresented: $viewModel.presentShareSheet) {
                        if #available(iOS 16.0, *) {
                            ShareSheetView(activity: PocketItemActivity(url: viewModel.item.url))
                                .presentationDetents([.medium])
                        } else {
                            // For now, iOS 15 will be full screen as weird bug and presentationDetents not available
                            ShareSheetView(activity: PocketItemActivity(url: viewModel.item.url))
                        }
                    }
                // Instead of using existing code of overflow, we created a new SwiftUI view
                OverflowMenu()
                    .environmentObject(viewModel)
            }
        }
        .padding(.vertical, constants.verticalPadding)
    }
}
