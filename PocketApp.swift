// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketKit
import SwiftUI

@main
struct PocketApp: App {
    @UIApplicationDelegateAdaptor private var delegate: PocketAppDelegate

    @Environment(\.scenePhase)
    var scenePhase

    @StateObject private var rootViewModel = RootViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: rootViewModel)
                .onAppear {
                    PocketShortcuts.updateAppShortcutParameters()
                }
        }.onChange(of: scenePhase) { newValue in
            rootViewModel.scenePhaseDidChange(newValue)
        }
    }
}
