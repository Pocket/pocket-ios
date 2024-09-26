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
    var card: HomeCard

    @Query var items: [Item]
    var item: Item? {
        items.first
    }

    var savedItem: SavedItem? {
        item?.savedItem
    }

    @Environment(HomeCoordinator.self)
    var coordinator

    @State private var presentWebView: Bool = false

    init(card: HomeCard) {
        self.card = card
        let givenUrl = card.givenURL
        var itemDescriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.givenURL == givenUrl })
        itemDescriptor.fetchLimit = 1
        _items = Query(itemDescriptor, animation: .easeIn)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            makeImage()
            makeTextStack()
            Spacer()
            CardFooter(
                card: card,
                domain: item?.bestDomain,
                timeToRead: item?.timeToRead,
                isSaved: savedItem != nil && savedItem?.isArchived == false,
                isFavorite: savedItem?.isFavorite == true,
                isSyndicated: item?.isSyndicated == true
            )
            .padding(Constants.footerPadding)
        }
        .background(Color(UIColor(.ui.homeCellBackground)))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .padding(.vertical, Constants.layoutMargins.top)
        .shadow(color: Color(UIColor(.ui.border)), radius: Constants.shadowRadius, x: 0, y: 0)
        .fullScreenCover(isPresented: $presentWebView) {
            SFSafariView(url: URL(string: card.givenURL)!)
                .ignoresSafeArea(.all)
        }
        .onTapGesture {
            if let savedItem = savedItem, let ID = savedItem.remoteID {
                coordinator.navigateTo(ReadableRoute(.saved(ID)))
            } else if let syndicatedArticle = item?.syndicatedArticle {
                coordinator.navigateTo(ReadableRoute(.syndicated(syndicatedArticle.itemID)))
            } else if let slug = item?.collection?.slug {
                coordinator.navigateTo(NativeCollectionRoute(slug: slug))
            } else if URL(string: card.givenURL) != nil {
                presentWebView = true
            }
        }
    }
}

// MARK: View builders
private extension HeroCard {
    /// Iimage
    func makeImage() -> some View {
        RemoteImage(url: card.imageURL, imageSize: imageSize, usePlaceholder: true)
            .aspectRatio(Constants.imageAspectRatio, contentMode: .fit)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity)
            .clipped()
            .padding(.bottom, Constants.mainVStackSpacing)
    }

    /// Text content of the Hero View
    func makeTextStack() -> some View {
        VStack(alignment: .leading, spacing: Constants.textStackSpacing) {
            if item?.isCollection == true {
                Text(Localization.Constants.collection)
                    .style(card.collectionStyle)
                    .accessibilityIdentifier("collection-label")
            }

            Text(item?.bestTitle ?? card.givenURL)
                .style(card.titleStyle)
                .lineSpacing(Constants.titleLineSpacing)
                .lineLimit(Constants.numberOfTitleLines)
                .accessibilityIdentifier("title-label")

            if let excerptText = card.attributedExcerpt {
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
