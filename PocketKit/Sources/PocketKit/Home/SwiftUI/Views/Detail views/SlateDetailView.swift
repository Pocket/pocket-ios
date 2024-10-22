// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct SlateDetailView: View {
    let route: SlateRoute

    @Query private var recommendations: [Recommendation]
    @State private var cards: [HomeCard] = []

    init(route: SlateRoute) {
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
        makeList()
        .onChange(of: recommendations, initial: true) {
            if proposedCards != cards {
                cards = proposedCards
            }
        }
        .animation(.smooth, value: cards)
    }
}

// MARK: view builders
private extension SlateDetailView {
    func makeList() -> some View {
        List(cards) {
            CardView(card: $0, size: .large)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .contentMargins([.leading, .trailing], -4, for: .scrollContent)
        .listRowSpacing(8)
        .navigationTitle(route.slateTitle ?? "Pocket")
    }
}

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
}
