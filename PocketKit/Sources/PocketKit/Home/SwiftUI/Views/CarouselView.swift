// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct Carousel: View {
    let remoteID: String
    let recommendations: [Recommendation]
    let useGrid: Bool

    var body: some View {
        if useGrid {
            makeGrid()
        } else {
            makeCarousel()
        }
    }
}

private extension Carousel {
    func makeCarousel() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(recommendations) { recommendation in
                    if let item = recommendation.item {
                        CarouselCard(
                            model: HomeCardModel(
                                givenURL: item.givenURL,
                                imageURL: item.topImageURL
                            )
                        )
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .leading) {
            Spacer()
                .frame(width: 8)
        }
        .safeAreaInset(edge: .trailing) {
            Spacer()
                .frame(width: 8)
        }
    }

    func makeGrid() -> some View {
        let recs = recommendations.chunked(into: 2).map { RecommendationsRow(row: $0) }
        return Grid {
            ForEach(recs) { recRow in
                GridRow {
                    ForEach(recRow.row) { recommendation in
                        if let item = recommendation.item {
                            CarouselCard(
                                model: HomeCardModel(
                                    givenURL: item.givenURL,
                                    imageURL: item.topImageURL
                                )
                            )
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
    }
}
