// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
                ItemDetails(attributedTitle: viewModel.item.title, attributedDetail: viewModel.item.detail, attributedCollection: viewModel.item.collection)

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
                        ShareSheetView(activity: PocketItemActivity.fromSaves(url: viewModel.item.bestURL))
                            .presentationDetents([.medium])
                    }
                // Instead of using existing code of overflow, we created a new SwiftUI view
                OverflowMenu()
                    .environmentObject(viewModel)
            }
        }
        .padding(.vertical, constants.verticalPadding)
    }
}
