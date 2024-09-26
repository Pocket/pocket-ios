// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftData
import SwiftUI
import Sync

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading) {
                    Text(Localization.home)
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading, 16)
                    RecentSavesView()
                        .padding(.bottom, 32)
                    SharedWithYouView()
                        .padding(.bottom, 32)
                    RecommendationsView()
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(.ui.white1))
            .navigationTitle(Localization.home)
            .navigationBarHidden(true)
            .environment(\.carouselWidth, carouselWidth(proxy.size.width))
            .environment(\.useWideLayout, useWideLayout())
        }
    }
}

// MARK: environment setup
private extension HomeView {
    /// Determine if the wide layout setting should be used
    func useWideLayout() -> Bool {
        horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Calculate carousel cell width based on which layout is being used
    func carouselWidth(_ proxyWidth: CGFloat) -> CGFloat {
        useWideLayout() ? proxyWidth * 0.5 - 64 : proxyWidth * 0.8
    }
}
