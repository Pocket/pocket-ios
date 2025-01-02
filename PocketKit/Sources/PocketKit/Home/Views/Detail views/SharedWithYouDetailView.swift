// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync
import SharedWithYou

struct SharedWithYouDetailView: View {
    let destination: SharedWithYouDestination
    // we re-fetch items here because in home we only have 5 items
    // also, this will allow to receive real time updates on items
    // e.g. when we save or remove them.
    @Query(sort: \SharedWithYouItem.sortOrder, order: .forward)
    private var sharedWithYouItems: [SharedWithYouItem]

    @State private var cards: [HomeCardConfiguration] = []

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @Environment(\.modelContext)
    private var modelContext

    var body: some View {
        GeometryReader { proxy in
            CardCollection(cards: cards, size: .large, layoutWidth: layoutWidth(proxy.size))
                .background(Color(.ui.white1))
        }
        .onChange(of: sharedWithYouItems, initial: true) {
            if proposedCards != cards {
                cards = proposedCards
            }
        }
        .animation(.smooth, value: cards)
        .navigationTitle(SWHighlightCenter.highlightCollectionTitle)
    }
}

// MARK: helpers
private extension SharedWithYouDetailView {
    var proposedCards: [HomeCardConfiguration] {
        sharedWithYouItems.enumerated().compactMap {
            if let item = fetchItem($0.element.url) {
                return HomeCardConfiguration(
                    givenURL: item.givenURL,
                    sharedWithYouUrlString: $0.element.url,
                    type: .sharedWithYouDetail,
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

    /// Fetch an `Item` from the underlying `SharedWithYouItem`
    /// - Parameter sharedWithYouUrl: `SharedWithYouItem` url
    /// - Returns: the item, if it was found
    func fetchItem(_ sharedWithYouUrl: String) -> Item? {
        let predicate = #Predicate<Item> { $0.sharedWithYouItem?.url == sharedWithYouUrl }
        var fetchDescriptor = FetchDescriptor(predicate: predicate)
        fetchDescriptor.fetchLimit = 1

        let result = (try? modelContext.fetch(fetchDescriptor)) ?? []
        return result.first
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
