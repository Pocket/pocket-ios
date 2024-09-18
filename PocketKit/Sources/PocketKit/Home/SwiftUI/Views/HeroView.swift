// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct HeroView: View {
    let remoteID: String
    let recommendations: [Recommendation]

    var body: some View {
        if recommendations.count == 1, let recommendation = recommendations.first, let item = recommendation.item {
            makeHeroCard(item)
        } else {
            makeHeroGrid()
        }
    }
}

private extension HeroView {
    @ViewBuilder
    func makeHeroCard(_ item: Item) -> some View {
            HeroCard(
                model: HomeCardModel(
                    givenURL: item.givenURL,
                    imageURL: item.topImageURL,
                    uselargeTitle: true
                )
            )
    }

    func makeHeroGrid() -> some View {
        let items = recommendations.compactMap({ $0.item }).chunked(into: 2).map { ItemsRow(row: $0) }
        return Grid {
            ForEach(items) { itemsInRow in
                GridRow {
                    ForEach(itemsInRow.row) { item in
                        makeHeroCard(item)
                    }
                }
            }
        }
    }
}
