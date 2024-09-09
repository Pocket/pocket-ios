// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Kingfisher
import Textile

struct HomeHeroView: View {
    var model: ItemCellViewModel
    // TODO: this will reflect the state of the saved item
    @State private var state: SaveButtonState

    init(model: ItemCellViewModel) {
        self.model = model
        switch model.saveButtonMode {
        case .save:
            self.state = .save
        case .saved:
            self.state = .saved
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageUrl = model.imageURL {
                loadImage(from: imageUrl)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            VStack(alignment: .leading, spacing: 4) {
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
            }
            .padding()

            HStack {
                VStack(alignment: .leading) {
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
                        .foregroundColor(Color(.ui.saveButtonText))
                }
                .accessibilityIdentifier("overflow-button")
            }
            .padding(.top, Constants.stackSpacing)
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
        .background(Color(UIColor(.ui.homeCellBackground)))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .padding(.vertical, Constants.layoutMargins.top)
        .shadow(color: Color(UIColor(.ui.border)), radius: 6, x: 0, y: 0)
        .listRowSeparator(.hidden)
        .listRowSpacing(0)
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
