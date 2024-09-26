// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct HeroView: View {
    let remoteID: String
    let cards: [HomeCard]

    var body: some View {
        if cards.count == 1, let card = cards.first {
            makeHeroCard(card)
        } else {
            makeHeroGrid()
        }
    }
}

// MARK: View builders
private extension HeroView {
    func makeHeroCard(_ card: HomeCard) -> some View {
        HeroCard(card: card)
    }

    func makeHeroGrid() -> some View {
        let itemsRows = cards.chunked(into: 2).map { HomeRow(cards: $0) }

        return Grid(horizontalSpacing: Self.defaultSpacing, verticalSpacing: Self.defaultSpacing) {
            ForEach(itemsRows) { itemsRow in
                GridRow {
                    ForEach(itemsRow.cards) { card in
                        HeroCard(
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
private extension HeroView {
    static let defaultSpacing: CGFloat = 16
    static let rowSize: Int = 2
    static let gridInsets = EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
}
