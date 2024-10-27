// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Lottie
import SwiftUI
import Textile

/// Display an array of cards, of the given size
/// The arrangement depends on the current `LayoutWidth`:
/// - `compact`: vertical list
/// - `wide`: 2-column vertical grid
/// - `extraWide`: 3-column vertical grid
struct CardCollection: View {
    let cards: [HomeCard]
    let size: CardSize
    let layoutWidth: LayoutWidth

    @State private var showEndOfFeed: Bool = false

    @Namespace private var scrollViewCoordinateSpace

    var body: some View {
        EndOfFeedScrollView {
            makeContent()
        }
    }
}

// MARK: View builders
private extension CardCollection {
    var itemsRows: [HomeRow] {
        cards.chunked(into: layoutWidth.preferredNumberOfColumns).map { HomeRow(cards: $0) }
    }
    @ViewBuilder
    func makeContent() -> some View {
        switch layoutWidth {
        case .compact:
            ForEach(cards) { card in
                CardView(card: card, size: size)
                    .padding(.bottom, 8)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        case .wide, .extraWide:
            Grid(horizontalSpacing: Self.defaultSpacing, verticalSpacing: Self.defaultSpacing) {
                ForEach(itemsRows) { itemsRow in
                    GridRow {
                        ForEach(itemsRow.cards) { card in
                            CardView(
                                card: card,
                                size: .large
                            )
                        }
                    }
                }
            }
            .padding(Self.gridInsets)
        }
    }
}

// MARK: constants
private extension CardCollection {
    static let defaultSpacing: CGFloat = 16
    static let rowSize: Int = 2
    static let gridInsets = EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
}
