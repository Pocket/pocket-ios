// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Kingfisher
import SwiftData
import SwiftUI
import Sync
import Textile

struct HeroCard: View {
    var model: HomeCardModel

    @Query var savedItem: [SavedItem]
    var currentSavedItem: SavedItem? {
        savedItem.first
    }

    @Query var item: [Item]
    var currentItem: Item? {
        item.first
    }

    init(model: HomeCardModel) {
        self.model = model
        let givenUrl = model.givenURL
        var savedItemDescriptor = FetchDescriptor<SavedItem>(predicate: #Predicate<SavedItem> { $0.item?.givenURL == givenUrl })
        savedItemDescriptor.fetchLimit = 1
        _savedItem = Query(savedItemDescriptor, animation: .easeIn)

        var itemDescriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.givenURL == givenUrl })
        itemDescriptor.fetchLimit = 1
        _item = Query(itemDescriptor, animation: .easeIn)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            makeImage()
            makeTextStack()
            Spacer()
            CardFooter(
                model: model,
                domain: currentItem?.bestDomain,
                timeToRead: currentItem?.timeToRead,
                isSaved: currentSavedItem != nil && currentSavedItem?.isArchived == false,
                isFavorite: currentSavedItem?.isFavorite == true,
                isSyndicated: currentItem?.isSyndicated == true
            )
            .padding(Constants.footerPadding)
        }
        .background(Color(UIColor(.ui.homeCellBackground)))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .padding(.vertical, Constants.layoutMargins.top)
        .shadow(color: Color(UIColor(.ui.border)), radius: Constants.shadowRadius, x: 0, y: 0)
    }
}

// MARK: View builders
private extension HeroCard {
    /// Iimage
    func makeImage() -> some View {
        RemoteImage(url: model.imageURL, imageSize: imageSize)
            .aspectRatio(Constants.imageAspectRatio, contentMode: .fit)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity)
            .clipped()
            .padding(.bottom, Constants.mainVStackSpacing)
    }

    /// Text content of the Hero View
    func makeTextStack() -> some View {
        VStack(alignment: .leading, spacing: Constants.textStackSpacing) {
            if currentItem?.isCollection == true {
                Text(Localization.Constants.collection)
                    .style(model.collectionStyle)
                    .accessibilityIdentifier("collection-label")
            }

            Text(currentItem?.bestTitle ?? model.givenURL)
                .style(model.titleStyle)
                .lineSpacing(Constants.titleLineSpacing)
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
extension HeroCard {
    enum Constants {
        // General
        static let mainVStackSpacing: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 6
        static let layoutMargins = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        // Image
        static let imageAspectRatio: CGFloat = 16/9
        // Text
        static let titleLineSpacing: CGFloat = 4
        static let textStackSpacing: CGFloat = 4
        static let numberOfTitleLines = 3
        static let numberOfSubtitleLines = 2
        static let textPadding = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        // Footer
        static let numberOfTimeToReadLines = 1
        static let footerPadding = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
    }
}
