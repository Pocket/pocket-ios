// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Kingfisher
import SwiftData
import SwiftUI
import Sync
import Textile

struct HomeHeroView: View {
    var model: HomeCardModel
    @Query var savedItem: [SavedItem]

    var currentSavedItem: SavedItem? {
        savedItem.first
    }

    init(model: HomeCardModel) {
        self.model = model
        let givenUrl = model.item.givenURL
        var descriptor = FetchDescriptor<SavedItem>(predicate: #Predicate<SavedItem> { $0.item?.givenURL == givenUrl })
        descriptor.fetchLimit = 1
        _savedItem = Query(descriptor, animation: .default)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            makeImage()
            makeTextStack()
            makeFooter()
        }
        .background(Color(UIColor(.ui.homeCellBackground)))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .padding(.vertical, Constants.layoutMargins.top)
        .shadow(color: Color(UIColor(.ui.border)), radius: Constants.shadowRadius, x: 0, y: 0)
        .listRowSeparator(.hidden)
        .listRowSpacing(0)
    }
}

// MARK: View builders
private extension HomeHeroView {
    /// Iimage
    func makeImage() -> some View {
        RemoteImage(url: model.imageURL, imageSize: imageSize)
            .aspectRatio(Constants.imageAspectRatio, contentMode: .fit)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity)
            .clipped()
    }

    /// Text content of the Hero View
    func makeTextStack() -> some View {
        VStack(alignment: .leading, spacing: Constants.textStackSpacing) {
            if let collectionText = model.attributedCollection {
                Text(collectionText)
                    .lineLimit(Constants.numberOfCollectionLines)
                    .accessibilityIdentifier("collection-label")
            }

            Text(model.attributedTitle)
                .lineLimit(Constants.numberOfTitleLines)
                .accessibilityIdentifier("title-label")

            if let excerptText = model.attributedExcerpt {
                Text(excerptText)
                    .lineLimit(nil)
                    .accessibilityIdentifier("excerpt-text")
            }
        }
        .padding(Constants.textPadding)
    }

    /// Footer
    func makeFooter() -> some View {
        HStack {
            makeFooterDescription()
            Spacer()
            makeSaveButton()
            makeOverflowMenu()
        }
        .padding(Constants.footerPadding)
    }

    /// Descriptive portion of the footer, containing domain and time to read
    func makeFooterDescription() -> some View {
        VStack(alignment: .leading) {
            Text(model.attributedDomain)
                .lineLimit(Constants.numberOfSubtitleLines)
                .accessibilityIdentifier("domain-label")

            Text(model.attributedTimeToRead)
                .lineLimit(Constants.numberOfTimeToReadLines)
                .accessibilityIdentifier("time-to-read-label")
        }
    }

    /// Save/saved button
    func makeSaveButton() -> some View {
        HomeActionButton(
            isActive: currentSavedItem?.isArchived == false,
            activeImage: .saved,
            inactiveImage: .save,
            activeTitle: Localization.Recommendation.saved,
            inactiveTitle: Localization.Recommendation.save,
            highlightedColor: .ui.coral1,
            activeColor: .ui.coral2
        ) {
            // isSaved.toggle()
        }
        .accessibilityIdentifier("save-button")
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            ForEach(model.overflowActions, id: \.self) { buttonAction in
                if let title = buttonAction.title {
                    Button(action: {
                        buttonAction.action()
                    }) {
                        Text(title)
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(Color(.ui.saveButtonText))
        }
        .accessibilityIdentifier("overflow-button")
    }

    /// The size of the image to be used by `RemoteImage`
    var imageSize: CGSize {
        let width = UIScreen.main.bounds.width
        let imageWidth = width - Constants.layoutMargins.leading - Constants.layoutMargins.trailing
        return CGSize(
            width: imageWidth,
            height: (imageWidth * (1 / Constants.imageAspectRatio)).rounded(.down)
        )
    }
}

// MARK: Appearance constants
extension HomeHeroView {
    enum Constants {
        // General
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 6
        static let layoutMargins = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        // Image
        static let imageAspectRatio: CGFloat = 16/9
        // Text
        static let textStackSpacing: CGFloat = 4
        static let numberOfCollectionLines = 1
        static let numberOfTitleLines = 3
        static let numberOfSubtitleLines = 2
        static let textPadding = EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        // Footer
        static let numberOfTimeToReadLines = 1
        static let footerPadding = EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 16)
    }
}
