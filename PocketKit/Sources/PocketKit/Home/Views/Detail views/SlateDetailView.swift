// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct SlateDetailView: View {
    let destination: SlateDestination

    @Query private var recommendations: [Recommendation]

    @State private var cards: [HomeCardConfiguration] = []

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    @Environment(\.homeActions)
    private var homeActions

    @Environment(\.modelContext)
    private var modelContext

    init(destination: SlateDestination) {
        self.destination = destination
        let slateID = destination.slateID
        let sortDescriptor = SortDescriptor<Recommendation>(\.sortIndex, order: .forward)
        let fetchDescriptor = FetchDescriptor(
            predicate: #Predicate<Recommendation> { $0.slate?.remoteID == slateID },
            sortBy: [sortDescriptor]
        )
        _recommendations = Query(fetchDescriptor)
    }

    var body: some View {
        GeometryReader { proxy in
            CardCollection(cards: cards, size: .large, layoutWidth: layoutWidth(proxy.size))
                .background(Color(.ui.white1))
        }
        .onChange(of: recommendations, initial: true) {
            if proposedCards != cards {
                cards = proposedCards
            }
        }
        .onAppear {
            homeActions.trackSlateDetailImpression(destination.slateID)
        }
        .animation(.smooth, value: cards)
        .navigationTitle(destination.slateTitle ?? "")
        .accessibilityIdentifier("slate-detail")
    }
}

// MARK: helpers
private extension SlateDetailView {
    var proposedCards: [HomeCardConfiguration] {
        recommendations.enumerated().compactMap {
            if let item = fetchItem($0.element.remoteID) {
                return HomeCardConfiguration(
                    givenURL: item.givenURL,
                    sharedWithYouUrlString: nil,
                    type: .slateDetail,
                    index: $0.offset,
                    shareURL: item.shareURL,
                    domain: item.domain,
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

    /// Fetch an `Item` from the underlying `Recommendation`
    /// - Parameter recommendationID: `Recommendation` ID
    /// - Returns: the item, if it was found
    func fetchItem(_ recommendationID: String) -> Item? {
        let predicate = #Predicate<Item> { $0.recommendation?.remoteID == recommendationID }
        var fetchDescriptor = FetchDescriptor(predicate: predicate)
        fetchDescriptor.fetchLimit = 1

        let result = (try? modelContext.fetch(fetchDescriptor)) ?? []
        return result.first
    }

    /// Fettch the current slate lineup
    /// - Returns: the slate lineup, if it was found
    func fetchSlateLineup() -> SlateLineup? {
        // there is only one lineup, so we don't need to filter this query
        let predicate = #Predicate<SlateLineup> { _ in
            return true
        }
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
