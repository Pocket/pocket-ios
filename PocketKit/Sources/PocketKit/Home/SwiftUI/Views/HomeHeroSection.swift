// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct HomeHeroSection: View {
    let remoteID: String
    let recommendations: [Recommendation]

    var body: some View {
        if recommendations.count == 1, let recommendation = recommendations.first {
            makeHeroView(recommendation)
        } else {
            makeHeroGrid()
        }
    }
}

private extension HomeHeroSection {
    @ViewBuilder
    func makeHeroView(_ recommendation: Recommendation) -> some View {
        if let item = recommendation.item {
            HomeHeroView(
                model: HomeCardModel(
                    givenURL: item.givenURL,
                    imageURL: recommendation.item?.topImageURL,
                    uselargeTitle: true
                )
            )
        } else {
            EmptyView()
        }
    }

    func makeHeroGrid() -> some View {
        let recs = recommendations.chunked(into: 2).map { RecommendationsRow(row: $0) }
        return Grid {
            ForEach(recs) { recRow in
                GridRow {
                    ForEach(recRow.row) { recommendation in
                        makeHeroView(recommendation)
                    }
                }
            }
        }
    }
}
