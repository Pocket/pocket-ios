// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct RecommendationsView: View {
    @Query(sort: \Slate.sortIndex, order: .forward)
    private var slates: [Slate]

    var body: some View {
        VStack(spacing: 32) {
            if !slates.isEmpty {
                ForEach(slates) {
                    if let recommendations = $0.recommendations, !recommendations.isEmpty {
                        SlateView(
                            remoteID: $0.remoteID,
                            slateTitle: $0.name,
                            cards: cards(for: recommendations)
                        )
                    }
                }
            } else {
                // TODO: SWIFTUI - Replace with the lottie animation
                Text("Pocket")
            }
        }
    }
}

private extension RecommendationsView {
    func cards( for recommendations: [Recommendation]) -> [HomeCard] {
        recommendations.compactMap {
            if let item = $0.item {
                return HomeCard(
                    givenURL: item.givenURL,
                    imageURL: item.topImageURL,
                    sharedWithYouUrlString: nil,
                    uselargeTitle: false
                )
            }
            return nil
        }
    }
}
