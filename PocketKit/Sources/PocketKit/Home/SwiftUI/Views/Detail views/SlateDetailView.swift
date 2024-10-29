// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct SlateDetailView: View {
    let route: SlateDestination

    @Query private var recommendations: [Recommendation]

    @State private var cards: [HomeCard] = []

    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    init(route: SlateDestination) {
        self.route = route
        let slateID = route.slateID
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
        .animation(.smooth, value: cards)
        .navigationTitle(route.slateTitle ?? "")
    }
}

// MARK: helpers
private extension SlateDetailView {
    var proposedCards: [HomeCard] {
        recommendations.compactMap {
            if let item = $0.item {
                return HomeCard(
                    givenURL: item.givenURL,
                    imageURL: item.topImageURL,
                    sharedWithYouUrlString: nil,
                    ShareURL: item.shareURL,
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
