// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import SwiftData

struct HomeSlateView: View {
    let remoteID: String
    let slateTitle: String
    @Query var recommendations: [Recommendation]

    init(remoteID: String, slateTitle: String) {
        self.remoteID = remoteID
        self.slateTitle = slateTitle
        // TODO: SWIFTUI - we might want to use a FetchDescriptor
        // also look into FetchResultsCollection
        let predicate = #Predicate<Recommendation> {
            $0.slate?.remoteID == remoteID
        }
        _recommendations = Query(filter: predicate, sort: \Recommendation.sortIndex, order: .forward)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // TODO: replace with section header
            Text(slateTitle)
            if let item = recommendations.first?.item {
                HomeHeroView(
                    model: HomeItemCellViewModel2(
                        item: item,
                        imageURL: item.topImageURL
                    )
                )
            }
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(recommendations.dropFirst()) { recommendation in
                        if let item = recommendation.item {
                            HomeCarouselView(
                                configuration: RecommendationCellConfiguration2(
                                    viewModel: HomeItemCellViewModel2(
                                        item: item,
                                        imageURL: item.topImageURL
                                    )
                                )
                            )
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding()
    }
}
