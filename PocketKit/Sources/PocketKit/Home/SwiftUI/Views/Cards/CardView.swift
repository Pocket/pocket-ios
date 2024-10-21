// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

/// Describes the supported card sizes (formats are similar to the widgets)
/// At the moment we support
///  - medium
///  - large
enum CardSize {
    case medium
    case large
}

/// Card view for the Home screen. Can have various sizes, specified by the `size` property.
struct CardView: View {
    let card: HomeCard
    let size: CardSize

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

    init(card: HomeCard, size: CardSize) {
        self.card = card
        self.size = size

        let givenUrl = card.givenURL
        var itemDescriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { $0.givenURL == givenUrl })
        itemDescriptor.fetchLimit = 1
        _items = Query(itemDescriptor, animation: .easeIn)
    }

    var body: some View {
        if let url = card.sharedWithYouUrlString {
            makeSharedWithYouCard(url)
        } else {
            makeSizedCard()
        }
    }
}

// MARK: View builders
private extension CardView {
    /// Builds the card of the current size
    /// - Returns: the card view
    @ViewBuilder
    func makeSizedCard() -> some View {
        switch size {
        case .medium:
            makeCard()
                .padding()
                .background(Color(.ui.homeCellBackground))
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .frame(minWidth: 0, idealWidth: carouselWidth, maxWidth: .infinity, idealHeight: Constants.cardHeight)
                .shadow(color: Color(.ui.border), radius: Constants.shadowRadius, x: 0, y: 0)
        case .large:
            makeCard()
                .background(Color(UIColor(.ui.homeCellBackground)))
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                .padding(.vertical, Constants.largeCardLayoutMargins.top)
                .shadow(color: Color(UIColor(.ui.border)), radius: Constants.shadowRadius, x: 0, y: 0)
        }
    }

    /// Size-agnostic card, containing card elements and behavior
    func makeCard() -> some View {
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
            .padding(Constants.footerPadding(size))
        }
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

    /// Builds a Shared With You card, which is a sized card with an attribution view at the bottom
    /// - Returns: the card view with the attribution view
    func makeSharedWithYouCard(_ urlString: String) -> some View {
        VStack {
            makeSizedCard()
            if let url = URL(string: urlString) {
                SharedWithYouAttributionView(url: url)
                    .frame(height: Constants.sharedWithYouAttributionViewHeight)
            }
        }
    }
    @ViewBuilder
    func makeTopContent() -> some View {
        switch size {
        case .medium:
            HStack(alignment: .top) {
                makeTextStack()
                Spacer()
                makeImage()
            }
        case .large:
            makeImage()
            makeTextStack()
        }
    }

    /// Text stack
    func makeTextStack() -> some View {
        VStack(alignment: .leading) {
            if item?.isCollection == true {
                Text(Localization.Constants.collection)
                    .style(card.collectionStyle)
                    .accessibilityIdentifier("collection-label")
            }
            Text(item?.bestTitle ?? card.givenURL)
                .style(card.titleStyle(largeTitle: size == .large))
                .lineSpacing(Constants.titleLineSpacing)
                .lineLimit(Constants.titleLineLimit)
                .accessibilityIdentifier("title-label")

            if let excerptText = card.attributedExcerpt {
                Text(excerptText)
                    .lineLimit(nil)
                    .accessibilityIdentifier("excerpt-text")
            }
        }
        .padding(Constants.textStackPadding(size))
    }

    /// Thumbnail
    @ViewBuilder
    func makeImage() -> some View {
        switch size {
        case .medium:
            VStack {
                RemoteImage(url: card.imageURL, imageSize: Constants.smallThumbnailSize, usePlaceholder: false)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.smallThumbnailSize.width, height: Constants.smallThumbnailSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                    .clipped()
                Spacer()
            }
        case .large:
            RemoteImage(url: card.imageURL, imageSize: largeImageSize, usePlaceholder: true)
                .aspectRatio(Constants.largeThumbnailAspectRatio, contentMode: .fit)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipped()
                .padding(.bottom, Constants.largeCardMainVStackSpacing)
        }
    }

    /// Calculates the image size of the large card based on the actual screen size
    var largeImageSize: CGSize {
        let width = UIScreen.main.bounds.width
        let imageWidth = width - Constants.largeCardLayoutMargins.leading - Constants.largeCardLayoutMargins.trailing
        return CGSize(
            width: imageWidth,
            height: (imageWidth * (1 / Constants.largeThumbnailAspectRatio)).rounded(.down)
        )
    }
}

// MARK: Appearance constants
private extension CardView {
    enum Constants {
        // General
        static let cornerRadius: CGFloat = 16
        static var cardHeight: CGFloat {
            min(UIFontMetrics.default.scaledValue(for: 146), 300)
        }
        static let sharedWithYouAttributionViewHeight: CGFloat = 32
        static let shadowRadius: CGFloat = 6
        static let largeCardLayoutMargins = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        static let largeCardMainVStackSpacing: CGFloat = 16
        // Thumbnail
        static let smallThumbnailSize = CGSize(width: 90, height: 60)
        static let largeThumbnailAspectRatio: CGFloat = 16/9
        // Title
        static let titleLineLimit = 3
        static let titleLineSpacing: CGFloat = 4
        // Text stack
        static func textStackPadding(_ size: CardSize) -> EdgeInsets {
            switch size {
            case .medium:
                return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            case .large:
                return EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
            }
        }
        // Footer
        static func footerPadding(_ size: CardSize) -> EdgeInsets {
            switch size {
            case .medium:
                return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            case .large:
                return EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
            }
        }
    }
}
