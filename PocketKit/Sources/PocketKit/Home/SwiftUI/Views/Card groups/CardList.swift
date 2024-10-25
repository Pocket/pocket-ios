// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Lottie
import SwiftUI
import Textile

/// Display an array of cards, of the given size, in a list
struct CardList: View {
    let cards: [HomeCard]
    let size: CardSize

    @State private var showEndOfFeed: Bool = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ForEach(cards) { card in
                        CardView(card: card, size: size)
                            .padding(.bottom, 8)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    Rectangle()
                        .fill(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .background {
                            GeometryReader { geometry in
                                VStack(alignment: .center) {
                                    HStack {
                                        Spacer()
                                        if showEndOfFeed {
                                            EndOfFeedView()
                                        }
                                        Spacer()
                                    }
                                }
                                .opacity(opacity)
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("ListView")).maxY
                                )
                            }
                        }
                }
            }
            .coordinateSpace(.named("ListView"))
            .contentMargins([.leading, .trailing], 16, for: .scrollContent)
            .background(Color.clear)
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            let shouldTriggerEndOfFeed = offset > 0 && offset < UIScreen.main.bounds.height - 200
            if showEndOfFeed != shouldTriggerEndOfFeed {
                showEndOfFeed = shouldTriggerEndOfFeed
                withAnimation(.smooth) {
                    if shouldTriggerEndOfFeed {
                        opacity = 1
                    } else {
                        opacity = 0
                    }
                }
            }
        }
        .background(Color(.ui.white1))
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
