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
    let card: HomeCardConfiguration
    let size: CardSize

    @Environment(\.carouselWidth)
    private var carouselWidth
    @Environment(\.homeActions)
    private var homeActions

    @EnvironmentObject private var navigation: HomeNavigation

    @State private var presentWebView: Bool = false

    @Query private var fetchedSavedItem: [SavedItem]
    private var savedItem: SavedItem? {
        fetchedSavedItem.first
    }

    init(card: HomeCardConfiguration, size: CardSize) {
        self.card = card
        self.size = size

        let givenUrl = card.givenURL
        var savedItemDescriptor = FetchDescriptor<SavedItem>(predicate: #Predicate<SavedItem> { $0.item?.givenURL == givenUrl })
        savedItemDescriptor.fetchLimit = 1
        _fetchedSavedItem = Query(savedItemDescriptor, animation: .easeInOut)
    }

    var body: some View {
        if #available(iOS 18.0, *) {
            makeBody()
                .onScrollVisibilityChange(threshold: 0.5) { isVisible in
                    if isVisible {
                        homeActions
                            .trackCardImpression(
                                AnalyticsInfo(
                                    type: card.type,
                                    url: card.givenURL,
                                    index: card.index,
                                    recommendationID: card.recommendationID
                                )
                            )
                    }
                }
        } else {
            makeBody()
        }
    }
}

// MARK: View builders
private extension CardView {
    @ViewBuilder
    func makeBody() -> some View {
        if let url = card.sharedWithYouUrlString {
            makeSharedWithYouCard(url)
        } else {
            makeSizedCard()
        }
    }
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
                shareURL: card.shareURL,
                domain: card.domain,
                timeToRead: card.timeToRead,
                isSaved: savedItem != nil && savedItem?.isArchived == false,
                isFavorite: savedItem?.isFavorite == true,
                isSyndicated: card.isSyndicated,
                recommendationID: card.recommendationID
            )
            .padding(Constants.footerPadding(size))
        }
        .contentShape(Rectangle())
        .fullScreenCover(isPresented: $presentWebView) {
            SFSafariView(url: URL(string: card.givenURL)!)
                .ignoresSafeArea(.all)
        }
        .onTapGesture {
            // property that determines if the content is opened in Pocket or in a webview, for analytics purposes
            var externalDestination = false
            if let slug = card.slug {
                navigation.navigateTo(NativeCollectionDestination(slug: slug, givenURL: card.givenURL))
            } else if let savedItem,                                                // We are legally allowed to open the item in reader view
                        savedItem.item?.isArticle == true,                          // except one of the following conditions is met:
                        savedItem.item?.isVideo == false,                           // a) the item is not an article (i.e. it was not parseable)
                        savedItem.item?.isImage == false {                          // b) the item is an image
                navigation.navigateTo(ReadableDestination(.saved(card.givenURL)))   // c) the item is a video
            } else if card.isSyndicated {
                navigation.navigateTo(ReadableDestination(.syndicated(card.givenURL)))
            } else if URL(string: card.givenURL) != nil {
                externalDestination = true
                presentWebView = true
            }
            homeActions.trackCardContentOpen(
                AnalyticsInfo(
                    type: card.type,
                    url: card.givenURL,
                    index: card.index,
                    recommendationID: card.recommendationID,
                    externalDestination: externalDestination
                )
            )
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
            makeMediumTopContnet()
        case .large:
            makeLargeTopContnet()
        }
    }

    @ViewBuilder
    func makeMediumTopContnet() -> some View {
        if #available(iOS 18.0, *) {
            HStack(alignment: .top) {
                makeTextStack()
                Spacer()
                makeImage()
            }
        } else {
            HStack(alignment: .top) {
                makeTextStack()
                Spacer()
                LazyHStack {
                    Spacer()
                        .frame(width: 1)
                        .onAppear {
                            homeActions
                                .trackCardImpression(
                                    AnalyticsInfo(
                                        type: card.type,
                                        url: card.givenURL,
                                        index: card.index,
                                        recommendationID: card.recommendationID
                                    )
                                )
                        }
                }
                makeImage()
            }
        }
    }

    @ViewBuilder
    func makeLargeTopContnet() -> some View {
        if #available(iOS 18.0, *) {
            makeImage()
            makeTextStack()
        } else {
            makeImage()
            LazyVStack {
                Spacer()
                    .frame(height: 1)
                    .onAppear {
                        homeActions
                            .trackCardImpression(
                                AnalyticsInfo(
                                    type: card.type,
                                    url: card.givenURL,
                                    index: card.index,
                                    recommendationID: card.recommendationID
                                )
                            )
                    }
            }
            makeTextStack()
        }
    }

    /// Text stack
    func makeTextStack() -> some View {
        VStack(alignment: .leading) {
            if card.slug != nil {
                Text(Localization.Constants.collection)
                    .style(.recommendation.collection)
                    .accessibilityIdentifier("collection-label")
            }
            Text(card.bestTitle ?? card.givenURL)
                .style(makeTitleStyle(largeTitle: !card.showExcerpt && size == .large))
                .lineSpacing(Constants.titleLineSpacing)
                .lineLimit(Constants.titleLineLimit)
                .accessibilityIdentifier("title-label")

            if card.showExcerpt,
                let excerpt = card.excerpt,
                let attributedExcerpt = try? AttributedString(
                markdown: excerpt,
                options: .init(
                    allowsExtendedAttributes: true,
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
               ) {
                Text(attributedExcerpt)
                    .style(.recommendation.excerpt)
                    .lineLimit(nil)
                    .accessibilityIdentifier("excerpt-text")
                    .padding(.top, 8)
            }
        }
        .padding(Constants.textStackPadding(size))
    }

    func makeTitleStyle(largeTitle: Bool) -> Style {
        .recommendation.adaptiveTitle(largeTitle)
    }

    /// Thumbnail
    @ViewBuilder
    func makeImage() -> some View {
        switch size {
        case .medium:
            VStack {
                RemoteImage(url: card.topImageURL, imageSize: Constants.smallThumbnailSize, usePlaceholder: false)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.smallThumbnailSize.width, height: Constants.smallThumbnailSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                    .clipped()
                Spacer()
            }
        case .large:
            RemoteImage(url: card.topImageURL, imageSize: largeImageSize, usePlaceholder: true)
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
