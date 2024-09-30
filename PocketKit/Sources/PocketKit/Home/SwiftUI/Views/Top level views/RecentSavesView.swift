// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync
import Textile

struct RecentSavesView: View {
    @Query private var savedItems: [SavedItem]

    @EnvironmentObject private var mainViewModel: MainViewModel

    @State private var cards: [HomeCard] = []

    init() {
        let predicate = #Predicate<SavedItem> { $0.isArchived == false && $0.deletedAt == nil }
        let sortDescriptor = SortDescriptor<SavedItem>(\.createdAt, order: .reverse)
        var fetchDescriptor = FetchDescriptor<SavedItem>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 5
        _savedItems = Query(fetchDescriptor)
    }

    var body: some View {
        ZStack {
            makeBody()
        }
        // TODO: SWIFTUI -  the animation included with @Query does not seem to behave as we want, so we do it here
        .onChange(of: savedItems, initial: true) {
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

private extension RecentSavesView {
    @ViewBuilder
    func makeBody() -> some View {
        if !cards.isEmpty {
            LazyVStack(alignment: .leading, spacing: 0) {
                makeHeader()
                CarouselView(cards: cards, useGrid: false)
                    .padding(.bottom, 32)
            }
        } else {
            Spacer()
                .frame(height: .zero)
        }
    }

    func makeHeader() -> some View {
        SectionHeader(title: Localization.recentSaves) {
            mainViewModel.selectedSection = .saves
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }

    var proposedCards: [HomeCard] {
        savedItems.compactMap {
            HomeCard(
                givenURL: $0.item?.givenURL ?? $0.url,
                imageURL: $0.item?.topImageURL,
                sharedWithYouUrlString: nil,
                ShareURL: $0.item?.shareURL,
                uselargeTitle: false,
                enableFavoriteAction: true,
                enableShareMenuAction: true,
                enableArchiveMenuAction: true,
                enableDeleteMenuAction: true
            )
        }
    }
}
