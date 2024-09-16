// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct HomeCarouselView: View {
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
            makeFooter()
        }
        .padding()
        .background(Color(.ui.homeCellBackground))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .frame(minWidth: 0, idealWidth: carouselWidth, maxWidth: .infinity, idealHeight: Constants.cardHeight)
        .shadow(color: Color(.ui.border), radius: Constants.shadowRadius, x: 0, y: 0)
    }
}

// MARK: View builders
private extension HomeCarouselView {
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
                Text(model.attributedCollection)
            }
            Text(model.attributedTitle(currentItem?.bestTitle ?? model.givenURL))
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

    /// Footer
    func makeFooter() -> some View {
        HStack(alignment: .bottom) {
            makeFooterDescription()
            Spacer()
            HStack(alignment: .center) {
                makeActionButton()
                makeOverflowMenu()
            }
        }
    }

    /// Footer description
    func makeFooterDescription() -> some View {
        VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            if let domain = currentItem?.bestDomain {
                Text(model.attributedDomain(domain, isSyndicated: currentItem?.isSyndicated == true))
                    .lineLimit(Constants.footerElementLineLimit)
            }
            if let timeToRead = currentItem?.timeToRead, timeToRead > 0 {
                Text(model.timeToRead(timeToRead))
                    .lineLimit(Constants.footerElementLineLimit)
            }
        }
    }

    /// Action button: save/saved and/or favorite
    @ViewBuilder
    func makeActionButton() -> some View {
        HStack(alignment: .bottom) {
            if let favoriteAction = model.favoriteAction {
                makeFavoriteButton(handler: favoriteAction.action)
            }
                makeSaveButton()
        }
    }

    func makeFavoriteButton(handler: @escaping (() -> Void)) -> some View {
        HomeActionButton(
            isActive: currentSavedItem?.isFavorite == false,
            activeImage: .favoriteFilled,
            inactiveImage: .favorite,
            highlightedColor: .branding.amber1,
            activeColor: .branding.amber4,
            inactiveColor: .ui.grey8
        ) {
            handler()
        }
        .accessibilityIdentifier("save-button")
    }

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
            model.saveAction(isSaved: currentSavedItem != nil && currentSavedItem?.isArchived == false)
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
}

// MARK: Appearance constants
private extension HomeCarouselView {
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
