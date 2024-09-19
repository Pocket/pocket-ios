// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct CarouselView: View {
    let items: [Item]
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
                ForEach(items) { item in
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
        let itemsInRow = items.chunked(into: 2).map { ItemsRow(row: $0) }
        return Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(itemsInRow) { itemsRow in
                GridRow {
                    ForEach(itemsRow.row) { item in
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
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
    }
}
