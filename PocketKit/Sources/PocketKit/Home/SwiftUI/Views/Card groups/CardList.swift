// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

/// Display an array of cards, of the given size, in a list
struct CardList: View {
    let cards: [HomeCard]
    let size: CardSize

    @State private var showEndOfFeed: Bool = false
    @State private var proxyValues: ProxyValues = .zero

    var body: some View {
        ZStack {
            List(Array(cards.enumerated()), id: \.element) { card in
                CardView(card: card.element, size: size)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .background {
                        if card.offset == cards.count - 1 {
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: ProxyValues(maxY: geometry.frame(in: .named("ListView")).maxY, minY: geometry.frame(in: .named("ListView")).minY)
                                )
                            }
                        }
                    }
            }
            .background {
                if showEndOfFeed {
                    VStack {
                        Spacer()
                        EndOfFeedView()
                            .opacity(showEndOfFeed ? 1 : 0)
                    }
                }
            }
            .coordinateSpace(.named("ListView"))
            .listStyle(.plain)
            .contentMargins([.leading, .trailing], -4, for: .scrollContent)
            .listRowSpacing(8)
            .background(Color.clear)
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) {
            proxyValues = $0
            print("---")
            print(proxyValues)
            print(UIScreen.main.bounds.height)
            print(UIScreen.main.bounds.minY)
            print(UIScreen.main.bounds.midY)
            print(UIScreen.main.bounds.maxY)
            withAnimation {
                showEndOfFeed = proxyValues.maxY < UIScreen.main.bounds.height - 130
            }
        }
        .background(Color(.ui.white1))
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: ProxyValues = .zero
    static func reduce(value: inout ProxyValues, nextValue: () -> ProxyValues) {
        value = ProxyValues(maxY: value.maxY + nextValue().maxY, minY: value.minY + nextValue().minY)
    }
}

struct ProxyValues: Equatable {
    let maxY: CGFloat
    let minY: CGFloat

    static var zero: ProxyValues {
        ProxyValues(maxY: 0, minY: 0)
    }
}
