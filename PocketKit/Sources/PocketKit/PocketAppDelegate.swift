// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Analytics
import BackgroundTasks


public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    private let accessTokenStore: AccessTokenStore
    private let source: Sync.Source
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let session: Session
    private let refreshCoordinator: RefreshCoordinator

    convenience override init() {
        self.init(services: Services.shared)
    }

    init(services: Services) {
        self.accessTokenStore = services.accessTokenStore
        self.source = services.source
        self.tracker = services.tracker
        self.userDefaults = services.userDefaults
        self.session = services.session
        self.refreshCoordinator = services.refreshCoordinator
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !CommandLine.arguments.contains("disableSentry") {
            Crashlogger.start(dsn: Keys.shared.sentryDSN)
        }
        
        if CommandLine.arguments.contains("clearUserDefaults") {
            userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

        SignOutOnFirstLaunch(
            accessTokenStore: accessTokenStore,
            userDefaults: userDefaults
        ).signOutOnFirstLaunch()

        let staticDataCleaner = StaticDataCleaner(
            bundle: Bundle.main,
            source: source,
            userDefaults: userDefaults
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

        if let accessToken = ProcessInfo.processInfo.environment["accessToken"] {
            try? accessTokenStore.save(token: accessToken)
        }

        if let guid = ProcessInfo.processInfo.environment["sessionGUID"] {
            session.guid = guid
        }

        if let userID = ProcessInfo.processInfo.environment["sessionUserID"] {
            session.userID = userID
        }

        Textiles.initialize()
        setupTracker()
        refreshCoordinator.initialize()

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

private extension PocketAppDelegate {
    func setupTracker() {
        let key = Keys.shared.pocketApiConsumerKey
        let apiUser = APIUser(consumerKey: key)
        tracker.addPersistentContext(apiUser)
    }
}
