// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile


public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    private var accessTokenStore: AccessTokenStore
    private var source: Sync.Source

    convenience override init() {
        self.init(services: Services.shared)
    }

    init(services: Services) {
        self.accessTokenStore = services.accessTokenStore
        self.source = services.source
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Crashlogger.start(dsn: Keys.shared.sentryDSN)

        SignOutOnFirstLaunch(
            accessTokenStore: accessTokenStore,
            userDefaults: .standard
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

        return true
    }

    public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.sceneClass = UIWindowScene.self
        config.delegateClass = PocketSceneDelegate.self

        return config
    }
}
