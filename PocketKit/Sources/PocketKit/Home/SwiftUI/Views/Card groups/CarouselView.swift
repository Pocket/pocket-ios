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

// MARK: view builders
private extension CarouselView {
    func makeCarousel() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: Self.defaultSpacing) {
                ForEach(cards) {
                    CarouselCard(
                        card: $0
                    )
                    .padding(.vertical, Self.defaultSpacing)
                }
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .leading) {
            Spacer()
                .frame(width: Self.carouselInset)
        }
        .safeAreaInset(edge: .trailing) {
            Spacer()
                .frame(width: Self.carouselInset)
        }
    }

    func makeGrid() -> some View {
        let itemsRows = cards.chunked(into: 2).map { HomeRow(cards: $0) }
        return Grid(horizontalSpacing: Self.defaultSpacing, verticalSpacing: Self.defaultSpacing) {
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
        .padding(Self.gridInsets)
    }
}

// MARK: constants
private extension CarouselView {
    static let defaultSpacing: CGFloat = 16
    static let carouselInset: CGFloat = 8
    static let gridInsets = EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
}
