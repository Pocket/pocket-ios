// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct HomeCarouselView: View {
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
        VStack(alignment: .leading) {
            makeTopContent()
            Spacer()
            makeFooter()
        }
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .padding()
        .background(Color(UIColor(.ui.homeCellBackground)))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .shadow(color: Color(UIColor(.ui.border)), radius: Constants.shadowRadius, x: 0, y: 0)
        .listRowSeparator(.hidden)
        .listRowSpacing(0)
    }
}

// MARK: View builders
private extension HomeCarouselView {
    func makeTopContent() -> some View {
        HStack {
            makeTextStack()
            Spacer()
            makeImage()
        }
    }

    /// Text stack
    func makeTextStack() -> some View {
        VStack(alignment: .leading) {
            if let attributedCollection = model.attributedCollection {
                Text(attributedCollection)
                    .lineLimit(Constants.collectionLineLimit)
            }
            Text(model.attributedTitle)
                .lineLimit(Constants.titleLineLimit)
        }
    }

    /// Thumbnail
    func makeImage() -> some View {
        RemoteImage(url: model.imageURL, imageSize: Constants.thumbnailSize)
            .aspectRatio(contentMode: .fit)
            // .fixedSize(horizontal: false, vertical: true)
            .frame(width: Constants.thumbnailSize.width, height: Constants.thumbnailSize.height)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .clipped()
    }

    /// Footer
    func makeFooter() -> some View {
        HStack {
            makeFooterDescription()
            Spacer()
            makeActionButton()
            makeOverflowMenu()
        }
    }

    /// Footer description
    func makeFooterDescription() -> some View {
        VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            Text(model.attributedDomain)
                .lineLimit(Constants.footerElementLineLimit)
            Text(model.attributedTimeToRead)
                .lineLimit(Constants.footerElementLineLimit)
        }
    }

    /// Action button: save/saved and/or favorite
    @ViewBuilder
    func makeActionButton() -> some View {
        HStack {
            if let favoriteAction = model.favoriteAction {
                makeFavoriteButton(handler: favoriteAction.action)
            }
            if let saveAction = model.primaryAction {
                makeSaveButton(handler: saveAction.action)
            }
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

    func makeSaveButton(handler: @escaping (() -> Void)) -> some View {
        HomeActionButton(
            isActive: currentSavedItem?.isArchived == false,
            activeImage: .saved,
            inactiveImage: .save,
            activeTitle: Localization.Recommendation.saved,
            inactiveTitle: Localization.Recommendation.save,
            highlightedColor: .ui.coral1,
            activeColor: .ui.coral2
        ) {
            model.primaryAction?.action()
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
        static let collectionLineLimit = 1
        static let actionButtonImageSize = CGSize(width: 20, height: 20)
        static let layoutMargins = UIEdgeInsets(top: Margins.normal.rawValue, left: Margins.normal.rawValue, bottom: Margins.normal.rawValue, right: Margins.normal.rawValue)
        static let stackSpacing: CGFloat = 4
        static let shadowRadius: CGFloat = 6
    }
}
