// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct CarouselCard: View {
    let model: HomeCardModel

    @Environment(\.carouselWidth)
    private var carouselWidth

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
        var descriptor = FetchDescriptor<SavedItem>(predicate: #Predicate<SavedItem> { $0.item?.givenURL == givenUrl })
        descriptor.fetchLimit = 1
        _savedItem = Query(descriptor, animation: .easeIn)

        var itemDescriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.givenURL == givenUrl })
        itemDescriptor.fetchLimit = 1
        _item = Query(itemDescriptor, animation: .easeIn)
    }

    var body: some View {
        VStack(alignment: .leading) {
            makeTopContent()
            Spacer()
            CardFooter(
                model: model,
                domain: currentItem?.bestDomain,
                timeToRead: currentItem?.timeToRead,
                isSaved: currentSavedItem != nil && currentSavedItem?.isArchived == false,
                isFavorite: currentSavedItem?.isFavorite == true,
                isSyndicated: currentItem?.isSyndicated == true
            )
        }
        .padding()
        .background(Color(.ui.homeCellBackground))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .frame(minWidth: 0, idealWidth: carouselWidth, maxWidth: .infinity, idealHeight: Constants.cardHeight)
        .shadow(color: Color(.ui.border), radius: Constants.shadowRadius, x: 0, y: 0)
    }
}

// MARK: View builders
private extension CarouselCard {
    func makeTopContent() -> some View {
        HStack(alignment: .top) {
            makeTextStack()
            Spacer()
            makeImage()
        }
    }

    /// Text stack
    func makeTextStack() -> some View {
        VStack(alignment: .leading) {
            if currentItem?.isCollection == true {
                Text(Localization.Constants.collection)
                    .style(model.collectionStyle)
            }
            Text(currentItem?.bestTitle ?? model.givenURL)
                .style(model.titleStyle)
                .lineSpacing(Constants.titleLineSpacing)
                .lineLimit(Constants.titleLineLimit)
        }
    }

    /// Thumbnail
    func makeImage() -> some View {
        VStack {
            RemoteImage(url: model.imageURL, imageSize: Constants.thumbnailSize)
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.thumbnailSize.width, height: Constants.thumbnailSize.height)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .clipped()
            Spacer()
        }
    }
}

// MARK: Appearance constants
private extension CarouselCard {
    enum Constants {
        static let thumbnailSize = CGSize(width: 90, height: 60)
        static let cornerRadius: CGFloat = 16
        static let titleLineLimit = 3
        static let footerElementLineLimit = 2
        static let actionButtonImageSize = CGSize(width: 20, height: 20)
        static let layoutMargins = UIEdgeInsets(top: Margins.normal.rawValue, left: Margins.normal.rawValue, bottom: Margins.normal.rawValue, right: Margins.normal.rawValue)
        static let stackSpacing: CGFloat = 4
        static let shadowRadius: CGFloat = 6
        static let titleLineSpacing: CGFloat = 4
        static var cardHeight: CGFloat {
            min(UIFontMetrics.default.scaledValue(for: 146), 300)
        }
    }
}
