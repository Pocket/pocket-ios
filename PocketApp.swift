// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketKit
import SwiftUI

@main
struct PocketApp: App {
    @Environment(\.scenePhase)
    var scenePhase

    @UIApplicationDelegateAdaptor var delegate: PocketAppDelegate

    var body: some Scene {
        WindowGroup {
            RootView(model: RootViewModel())
        }.onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                delegate.scenePhaseDidChange(scenePhase)
            default: return
            }
        }
    }
}
