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
                VStack(alignment: .leading) {
                    Spacer()
                        .frame(height: 16)
                    RecentSavesView()
                    SharedWithYouView()
                    RecommendationsView()
                }
            }
            .scrollIndicators(.hidden)
            .background(Color(.ui.white1))
            .navigationTitle(Localization.home)
            .environment(\.carouselWidth, carouselWidth(proxy.size))
            .environment(\.layoutWidth, layoutWidth(proxy.size))
        }
    }
}

// MARK: environment setup
private extension HomeView {
    /// Determine the size of the current layout
    func layoutWidth(_ screenSize: CGSize) -> LayoutWidth {
        guard horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad else {
            return .compact
        }
        return screenSize.width > screenSize.height ? .extraWide : .wide
    }

    /// Calculate carousel cell width based on which layout is being used
    func carouselWidth(_ screenSize: CGSize) -> CGFloat {
        layoutWidth(screenSize).isRegular ? screenSize.width * 0.5 - 64 : screenSize.width * 0.8
    }
}
