// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct HomeCarouselView: View {
    var configuration: HomeCarouselCellConfiguration2
    // TODO: this will reflect the state of the saved item
    @State private var isSaved: Bool = false
    @State private var isFavorited: Bool = false

    init(configuration: HomeCarouselCellConfiguration2) {
        self.configuration = configuration
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
            if let attributedCollection = configuration.attributedCollection {
                Text(attributedCollection)
                    .lineLimit(Constants.collectionLineLimit)
            }
            Text(configuration.attributedTitle)
                .lineLimit(Constants.titleLineLimit)
        }
    }

    /// Thumbnail
    func makeImage() -> some View {
        RemoteImage(url: configuration.thumbnailURL, imageSize: Constants.thumbnailSize)
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
            Text(configuration.attributedDomain)
                .lineLimit(Constants.footerElementLineLimit)
            Text(configuration.attributedTimeToRead)
                .lineLimit(Constants.footerElementLineLimit)
        }
    }

    /// Action button: save/saved or favorite
    @ViewBuilder
    func makeActionButton() -> some View {
        if let favoriteAction = configuration.favoriteAction, let handler = favoriteAction.handler {
            makeFavoriteButton(handler: handler)
        } else if let saveAction = configuration.saveAction, let handler = saveAction.handler {
            makeSaveButton(handler: handler)
        }
    }

    func makeFavoriteButton(handler: @escaping ((Any?) -> Void)) -> some View {
        HomeActionButton(
            isActive: isFavorited,
            activeImage: .favoriteFilled,
            inactiveImage: .favorite,
            highlightedColor: .branding.amber1,
            activeColor: .branding.amber4,
            inactiveColor: .ui.grey8
        ) {
            handler(nil)
        }
        .accessibilityIdentifier("save-button")
    }

    func makeSaveButton(handler: @escaping ((Any?) -> Void)) -> some View {
        HomeActionButton(
            isActive: isSaved,
            activeImage: .saved,
            inactiveImage: .save,
            activeTitle: Localization.Recommendation.saved,
            inactiveTitle: Localization.Recommendation.save,
            highlightedColor: .ui.coral1,
            activeColor: .ui.coral2
        ) {
            handler(nil)
        }
        .accessibilityIdentifier("save-button")
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            ForEach(configuration.overflowActions ?? [], id: \.self) { action in
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
