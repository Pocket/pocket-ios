// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct HomeView: View {
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 32) {
                    RecentSavesView()
                    RecommendationsView()
                }
            }
            .environment(\.carouselWidth, proxy.size.width * 0.8)
        }
    }
}
