// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct CarouselCard: View {
    let card: HomeCard

    @Environment(\.carouselWidth)
    private var carouselWidth

    @Environment(HomeCoordinator.self)
    var coordinator

    @State private var presentWebView: Bool = false

    @Query private var items: [Item]

    private var item: Item? {
        items.first
    }

    private var savedItem: SavedItem? {
        item?.savedItem
    }

    init(card: HomeCard) {
        self.card = card

        let givenUrl = card.givenURL
        var itemDescriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.givenURL == givenUrl })
        itemDescriptor.fetchLimit = 1
        _items = Query(itemDescriptor, animation: .easeIn)
    }

    var body: some View {
        if let url = card.sharedWithYouUrlString {
            makeSharedWithYouCard(url)
        } else {
            makeGeneralCard()
        }
    }
}

// MARK: View builders
private extension CarouselCard {
    /// Builds a general purpose card, used for any item in a carousel
    /// - Returns: the card view
    func makeGeneralCard() -> some View {
        VStack(alignment: .leading) {
            makeTopContent()
            Spacer()
            CardFooter(
                card: card,
                domain: item?.bestDomain,
                timeToRead: item?.timeToRead,
                isSaved: savedItem != nil && savedItem?.isArchived == false,
                isFavorite: savedItem?.isFavorite == true,
                isSyndicated: item?.isSyndicated == true,
                recommendationID: item?.recommendation?.analyticsID
            )
        }
        .padding()
        .background(Color(.ui.homeCellBackground))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .frame(minWidth: 0, idealWidth: carouselWidth, maxWidth: .infinity, idealHeight: Constants.cardHeight)
        .shadow(color: Color(.ui.border), radius: Constants.shadowRadius, x: 0, y: 0)
        .fullScreenCover(isPresented: $presentWebView) {
            SFSafariView(url: URL(string: card.givenURL)!)
                .ignoresSafeArea(.all)
        }
        .onTapGesture {
            if savedItem != nil {
                coordinator.navigateTo(ReadableRoute(.saved(card.givenURL)))
            } else if item?.syndicatedArticle != nil {
                coordinator.navigateTo(ReadableRoute(.syndicated(card.givenURL)))
            } else if let slug = item?.collection?.slug {
                coordinator.navigateTo(NativeCollectionRoute(slug: slug))
            } else if URL(string: card.givenURL) != nil {
                presentWebView = true
            }
        }
    }

    /// Builds a Shared With You card, which is a general carousel card with an attribution view at the bottom
    /// - Returns: the card view with the attribution view
    func makeSharedWithYouCard(_ urlString: String) -> some View {
        VStack {
            makeGeneralCard()
            if let url = URL(string: urlString) {
                SharedWithYouAttributionView(url: url)
                    .frame(height: Constants.sharedWithYouAttributionViewHeight)
            }
        }
    }
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
            if item?.isCollection == true {
                Text(Localization.Constants.collection)
                    .style(card.collectionStyle)
            }
            Text(item?.bestTitle ?? card.givenURL)
                .style(card.titleStyle(largeTitle: false))
                .lineSpacing(Constants.titleLineSpacing)
                .lineLimit(Constants.titleLineLimit)
        }
    }

    /// Thumbnail
    func makeImage() -> some View {
        VStack {
            RemoteImage(url: card.imageURL, imageSize: Constants.thumbnailSize, usePlaceholder: false)
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
        // General
        static let cornerRadius: CGFloat = 16
        static var cardHeight: CGFloat {
            min(UIFontMetrics.default.scaledValue(for: 146), 300)
        }
        static let sharedWithYouAttributionViewHeight: CGFloat = 32
        static let shadowRadius: CGFloat = 6
        // Thumbnail
        static let thumbnailSize = CGSize(width: 90, height: 60)
        // Title
        static let titleLineLimit = 3
        static let titleLineSpacing: CGFloat = 4
    }
}
