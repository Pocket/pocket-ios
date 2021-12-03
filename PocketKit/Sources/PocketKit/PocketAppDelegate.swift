// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Analytics
import BackgroundTasks


public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    private let source: Source
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let firstLaunchDefaults: UserDefaults
    private let sessionController: SessionController
    private let refreshCoordinator: RefreshCoordinator

    convenience override init() {
        self.init(services: Services.shared)
    }

    init(services: Services) {
        self.source = services.source
        self.tracker = services.tracker
        self.userDefaults = services.userDefaults
        self.firstLaunchDefaults = services.firstLaunchDefaults
        self.sessionController = services.sessionController
        self.refreshCoordinator = services.refreshCoordinator
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !CommandLine.arguments.contains("disableSentry") {
            Crashlogger.start(dsn: Keys.shared.sentryDSN)
        }

        if CommandLine.arguments.contains("clearKeychain") {
            sessionController.clearAccessToken()
        }

        if CommandLine.arguments.contains("clearUserDefaults") {
            userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }

        if CommandLine.arguments.contains("clearFirstLaunch") {
            firstLaunchDefaults.removePersistentDomain(
                forName: "\(Bundle.main.bundleIdentifier!).first-launch"
            )
        }

        if CommandLine.arguments.contains("clearCoreData") {
            source.clear()
        }

        if CommandLine.arguments.contains("clearImageCache") {
            Textiles.clearImageCache()
        }

        SignOutOnFirstLaunch(
            sessionController: sessionController,
            userDefaults: firstLaunchDefaults
        ).signOutOnFirstLaunch()

        StaticDataCleaner(
            bundle: Bundle.main,
            source: source,
            userDefaults: userDefaults
        ).clearIfNecessary()

        sessionController.updateSession(
            accessToken: ProcessInfo.processInfo.environment["accessToken"],
            guid: ProcessInfo.processInfo.environment["sessionGUID"],
            userID: ProcessInfo.processInfo.environment["sessionUserID"]
        )

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
        let apiUser = APIUserContext(consumerKey: key)
        tracker.addPersistentContext(apiUser)
    }
}
