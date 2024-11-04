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
        LazyVStack(spacing: 32) {
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
    func cards( for recommendations: [Recommendation]) -> [HomeCardConfiguration] {
        recommendations
            .sorted(by: { $0.sortIndex < $1.sortIndex })
            .prefix(6)
            .compactMap {
            if let item = $0.item {
                return HomeCardConfiguration(
                    givenURL: item.givenURL,
                    sharedWithYouUrlString: nil,
                    type: .recommendation,
                    index: Int(item.recommendation?.sortIndex ?? 0), // sortIndex should not be nil, but just in case, let's have a default
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
}
