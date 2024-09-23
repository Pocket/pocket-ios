// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct CarouselView: View {
    let cards: [HomeCard]
    let useGrid: Bool

    var body: some View {
        if useGrid {
            makeGrid()
        } else {
            makeCarousel()
        }
    }
}

private extension CarouselView {
    func makeCarousel() -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                ForEach(cards) {
                    CarouselCard(
                        card: $0
                    )
                    .padding(.vertical, 16)
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
        let itemsRows = cards.chunked(into: 2).map { HomeRow(cards: $0) }
        return Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(itemsRows) { itemsRow in
                GridRow {
                    ForEach(itemsRow.cards) { card in
                        CarouselCard(
                            card: card
                        )
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
    }
}
