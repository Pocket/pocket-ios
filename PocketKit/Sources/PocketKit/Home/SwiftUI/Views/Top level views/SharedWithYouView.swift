// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile
import SharedWithYou

struct SharedWithYouView: View {
    @Query private var sharedWithYouItems: [SharedWithYouItem]

    @EnvironmentObject var navigation: HomeNavigation

    @State private var cards: [HomeCardConfiguration] = []

    init() {
        let sortDescriptor = SortDescriptor<SharedWithYouItem>(\.sortOrder, order: .forward)
        var fetchDescriptor = FetchDescriptor<SharedWithYouItem>(sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 5
        _sharedWithYouItems = Query(fetchDescriptor, animation: .easeIn)
    }

    var body: some View {
        ZStack {
            makeBody()
        }
        // TODO: SWIFTUI -  the animation included with @Query does not seem to behave as we want, so we do it here
        .onChange(of: sharedWithYouItems, initial: true) {
            // this prevents unwanted view refreshes if the query updates (because Core Data receives updates)
            // but the recent saves do not actually change
            if proposedCards != cards {
                cards = proposedCards
            }
        }
        // TODO: SWIFTUI - this animation works well when removing on top of the list, not so well otherwise
        // investigate better animation options
        .animation(.smooth, value: cards)
    }
}

private extension SharedWithYouView {
    @ViewBuilder
    func makeBody() -> some View {
        if !cards.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                makeHeader(SWHighlightCenter.highlightCollectionTitle)
                CarouselView(cards: cards, useGrid: false)
            }
            .padding(.bottom, 32)
        } else {
            Spacer()
                .frame(height: .zero)
        }
    }
    func makeHeader(_ title: String) -> some View {
        SectionHeader(title: title) {
            navigation.navigateTo(SharedWithYouDestination(title: title))
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }

    var proposedCards: [HomeCardConfiguration] {
        sharedWithYouItems.enumerated().compactMap {
            HomeCardConfiguration(
                givenURL: $0.element.item?.givenURL ?? $0.element.url,
                sharedWithYouUrlString: $0.element.url,
                type: .sharedWithYou,
                index: $0.offset,
                shareURL: $0.element.item?.shareURL,
                domain: $0.element.item?.bestDomain,
                timeToRead: $0.element.item?.timeToRead,
                isSyndicated: $0.element.item?.isSyndicated == true,
                recommendationID: $0.element.item?.recommendation?.analyticsID,
                bestTitle: $0.element.item?.bestTitle,
                slug: $0.element.item?.collectionSlug,
                excerpt: $0.element.item?.excerpt,
                topImageURL: $0.element.item?.topImageURL,
                enableSaveAction: true,
                enableShareMenuAction: true,
                enableReportMenuAction: true
            )
        }
    }
}
