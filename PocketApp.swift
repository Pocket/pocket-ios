// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketKit
import SwiftUI

@main
struct PocketApp: App {
    @UIApplicationDelegateAdaptor var delegate: PocketAppDelegate

    @Environment(\.scenePhase)
    var scenePhase

    let rootViewModel: RootViewModel

    init() {
        self.rootViewModel = RootViewModel()
        rootViewModel.start()
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: rootViewModel)
        }.onChange(of: scenePhase) { newValue in
            rootViewModel.scenePhaseDidChange(newValue)
        }
    }
}
