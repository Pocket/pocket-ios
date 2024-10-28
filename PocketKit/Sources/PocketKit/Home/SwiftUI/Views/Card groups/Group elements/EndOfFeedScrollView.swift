// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

/// A container scroll view with an end-of-feed animation
struct EndOfFeedScrollView<Content: View, Header: View>: View {
    @State private var showEndOfFeed: Bool = false
    @Namespace private var scrollViewCoordinateSpace

    let content: Content
    let header: Header?

    init(@ViewBuilder content: @escaping () -> Content, header: (() -> Header)? = nil) {
        self.content = content()
        self.header = header?()
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                if let header {
                    header
                }
                content
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
                            .animation(.smooth, value: showEndOfFeed)
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named(scrollViewCoordinateSpace)).maxY
                            )
                        }
                    }
            }
        }
        .scrollIndicators(.hidden)
        .coordinateSpace(.named(scrollViewCoordinateSpace))
        .background(Color.clear)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
            let shouldTriggerEndOfFeed = offset > 0 && offset < UIScreen.main.bounds.height - 200
            if showEndOfFeed != shouldTriggerEndOfFeed {
                showEndOfFeed = shouldTriggerEndOfFeed
            }
        }
    }
}

extension EndOfFeedScrollView where Header == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.header = nil
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
