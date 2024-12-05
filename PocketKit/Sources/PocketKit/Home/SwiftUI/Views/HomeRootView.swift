// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct HomeRootView: View {
    // TODO: SWIFTUI - We might want to move this to the top app as we transition to a full SwiftUI app
    @StateObject private var homeNavigation: HomeNavigation

    @Environment(\.scenePhase)
    var scenePhase

    init(homeNavigation: HomeNavigation) {
        _homeNavigation = StateObject(wrappedValue: homeNavigation)
    }

    var body: some View {
        NavigationStack(path: $homeNavigation.path) {
            HomeView()
                .navigationDestination(for: NativeCollectionDestination.self) { NativeCollectionView(destination: $0) }
                .navigationDestination(for: ReadableDestination.self) {
                    ReaderView(destination: $0)
                        .ignoresSafeArea(.all)
                }
                .navigationDestination(for: SlateDestination.self) { SlateDetailView(destination: $0) }
                .navigationDestination(for: SharedWithYouDestination.self) { SharedWithYouDetailView(destination: $0) }
        }
        .accentColor(Color(.ui.black1))
        .environmentObject(homeNavigation)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .background {
                homeNavigation.savePath()
            }
        }
    }
}
