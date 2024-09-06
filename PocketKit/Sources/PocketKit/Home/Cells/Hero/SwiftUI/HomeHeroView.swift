// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Kingfisher
import Textile

struct HomeHeroView: View {
    var model: ItemCellViewModel
    // TODO: this will reflect the state of the saved item
    @State private var state: SaveButtonState = .save

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            if let imageUrl = model.imageURL {
                loadImage(from: imageUrl)
                    .resizable()
                    .aspectRatio(Constants.imageAspectRatio, contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - Constants.layoutMargins.leading - Constants.layoutMargins.trailing)
                    .cornerRadius(Constants.cornerRadius)
                    .clipped()
            }

            if let collectionText = model.attributedCollection {
                Text(AttributedString(collectionText))
                    .lineLimit(Constants.numberOfCollectionLines)
                    .accessibilityIdentifier("collection-label")
            }

            Text(AttributedString(model.attributedTitle))
                .lineLimit(Constants.numberOfTitleLines)
                .accessibilityIdentifier("title-label")

            if let excerptText = model.attributedExcerpt {
                Text(AttributedString(excerptText))
                    .lineLimit(nil)
                    .accessibilityIdentifier("excerpt-text")
            }

            HStack {
                VStack {
                    Text(AttributedString(model.attributedDomain))
                        .lineLimit(Constants.numberOfSubtitleLines)
                        .accessibilityIdentifier("domain-label")

                    Text(AttributedString(model.attributedTimeToRead))
                        .lineLimit(Constants.numberOfTimeToReadLines)
                        .accessibilityIdentifier("time-to-read-label")
                }
                Spacer()
                HomeSaveButton(state: $state) {
                    if let handler = model.primaryAction?.handler {
                        handler(nil)
                    }
                }
                .accessibilityIdentifier("save-button")

                Menu {
                    ForEach(model.overflowActions ?? [], id: \.self) { action in
                        if let handler = action.handler {
                            Button(action: {
                                handler(nil)
                            }) {
                                Text(action.title)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityIdentifier("overflow-button")
            }
            .padding(.top, Constants.stackSpacing)
        }
        .padding(.horizontal, Constants.layoutMargins.leading)
        .padding(.vertical, Constants.layoutMargins.top)
        .background(Color(UIColor(.ui.homeCellBackground)))
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Color(UIColor(.ui.border)), radius: 6, x: 0, y: 0)
    }

    private func loadImage(from url: URL) -> KFImage {
        let width = UIScreen.main.bounds.width
        let imageWidth = width - Constants.layoutMargins.leading - Constants.layoutMargins.trailing
        let imageSize = CGSize(
            width: imageWidth,
            height: (imageWidth * Constants.imageAspectRatio).rounded(.down)
        )
        return KFImage(url)
            .placeholder {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(.ui.grey4)))
            }
            .setProcessor(
                ResizingImageProcessor(
                referenceSize: imageSize,
                mode: .aspectFill
            )
                .append(
                    another: CroppingImageProcessor(
                        size: imageSize
                    )
                )
            )
            .callbackQueue(.dispatch(.global(qos: .userInteractive)))
            .backgroundDecode()
            .scaleFactor(UIScreen.main.scale)
    }
}

private extension HomeHeroView {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let textStackTopMargin: CGFloat = 16
        static let imageAspectRatio: CGFloat = 9/16
        static let numberOfCollectionLines = 1
        static let numberOfTitleLines = 3
        static let numberOfSubtitleLines = 2
        static let numberOfTimeToReadLines = 1
        static let layoutMargins = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        static let stackSpacing: CGFloat = 4
        static let textStackMiddleMargin: CGFloat = 12
        static let textStackBottomMargin: CGFloat = 12
    }
}
