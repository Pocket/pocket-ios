// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Apollo
import Sync
import Textile


class AppState: ObservableObject {
    @Published
    var authToken: String?
}

public struct PocketApp: App {
    @ObservedObject
    var appState = AppState()

    @Environment(\.accessTokenStore)
    private var accessTokenStore: AccessTokenStore

    @Environment(\.source)
    private var source: Sync.Source

    public init() {
        Crashlogger.start(dsn: Keys.shared.sentryDSN)
        SignOutOnFirstLaunch(
            accessTokenStore: accessTokenStore,
            userDefaults: UserDefaults.standard
        ).signOutOnFirstLaunch()

        let staticDataCleaner = StaticDataCleaner(
            bundle: Bundle.main,
            source: source
        )
        staticDataCleaner.clearIfNecessary()

        if CommandLine.arguments.contains("clearKeychain") {
            try? accessTokenStore.delete()
        }

        if CommandLine.arguments.contains("clearCoreData") {
            source.clear()
        }
        
        if CommandLine.arguments.contains("clearImageCache") {
            Textiles.clearImageCache()
        }
        
        Textiles.initialize()
        appState.authToken = accessTokenStore.accessToken
    }

    @ViewBuilder
    public var body: some Scene {
        WindowGroup {
            AppView(appState: appState)
                .environment(\.managedObjectContext, source.managedObjectContext)
        }
    }
}



struct AppView: View {
    @ObservedObject
    var appState: AppState
    
    var body: some View {
        if let token = appState.authToken {
            NavigationView {
                ItemListView(token: token)
                    .navigationTitle("My List")
            }
        } else {
            SignInView(authToken: $appState.authToken)
        }
    }
}
