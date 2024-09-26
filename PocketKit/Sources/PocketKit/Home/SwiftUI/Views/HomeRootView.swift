// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct HomeRootView: View {
    // TODO: SWIFTUI - We might want to move this to the top app as we transition to a full SwiftUI app
    @State private var homeCoordinator = HomeCoordinator()

    @Environment(\.scenePhase)
    var scenePhase

    var body: some View {
        NavigationStack(path: $homeCoordinator.path) {
            HomeView()
                .navigationDestination(for: NativeCollectionRoute.self) { NativeCollectionView(route: $0) }
                .navigationDestination(for: ReadableRoute.self) { ReaderView(route: $0) }
                .navigationDestination(for: SlateRoute.self) { SlateDetailView(route: $0) }
                .navigationDestination(for: SharedWithYouRoute.self) { SharedWithYouDetailView(route: $0) }
        }
        .environment(homeCoordinator)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .background {
                homeCoordinator.savePath()
            }
        }
    }
}
