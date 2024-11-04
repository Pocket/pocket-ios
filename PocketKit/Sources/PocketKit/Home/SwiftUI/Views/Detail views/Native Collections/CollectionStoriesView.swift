// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct CollectionStoriesView: View {
    let slug: String
    let header: CollectionHeader

    @Query private var stories: [CollectionStory]

    @State private var cards: [HomeCardConfiguration] = []

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    init(slug: String, header: CollectionHeader) {
        self.slug = slug
        self.header = header

        _stories = Query(
            filter: #Predicate {
                $0.collection?.slug == slug
            },
            sort: \CollectionStory.sortOrder,
            order: .forward
        )
    }

    var body: some View {
        GeometryReader { proxy in
            CardCollection(cards: cards, size: .large, layoutWidth: layoutWidth(proxy.size), header: header)
                .background(Color(.ui.white1))
        }
        .onChange(of: stories, initial: true) {
            if proposedCards != cards {
                cards = proposedCards
            }
        }
        .animation(.smooth, value: cards)
    }
}

// MARK: helpers
private extension CollectionStoriesView {
    var proposedCards: [HomeCardConfiguration] {
        stories.enumerated().compactMap {
            if let item = $0.element.item {
                return HomeCardConfiguration(
                    givenURL: item.givenURL,
                    sharedWithYouUrlString: nil,
                    showExcerpt: true,
                    type: .collectionStory,
                    index: $0.offset,
                    shareURL: item.shareURL,
                    domain: item.bestDomain,
                    timeToRead: item.timeToRead,
                    isSyndicated: item.isSyndicated,
                    recommendationID: item.recommendation?.analyticsID,
                    bestTitle: item.bestTitle,
                    slug: item.collectionSlug,
                    excerpt: item.excerpt,
                    topImageURL: item.topImageURL,
                    enableSaveAction: true,
                    enableShareMenuAction: true,
                    enableReportMenuAction: true
                )
            }
            return nil
        }
    }
    /// Determine the size of the current layout
    /// **NOTE: turns out that, since this is a detail view, the environment value `layoutWidth`
    /// cannot be used here since the GeometryReader of HomeView is not active
    func layoutWidth(_ screenSize: CGSize) -> LayoutWidth {
        guard horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad else {
            return .compact
        }
        return screenSize.width > screenSize.height ? .extraWide : .wide
    }
}
