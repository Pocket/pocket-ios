// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

class AppState: ObservableObject {
    @Published
    var authToken: String?
}

@main
struct PocketApp: App {
    @ObservedObject
    var appState = AppState()

    @Environment(\.accessTokenStore)
    private var accessTokenStore: AccessTokenStore

    init() {
        if CommandLine.arguments.contains("clearKeychain") {
            try? accessTokenStore.delete()
        }

        appState.authToken = accessTokenStore.accessToken
    }

    @ViewBuilder
    var body: some Scene {
        WindowGroup {
            if appState.authToken != nil {
                LoggedInView()
            } else {
                SignInView(authToken: $appState.authToken)
            }
        }
    }
}
