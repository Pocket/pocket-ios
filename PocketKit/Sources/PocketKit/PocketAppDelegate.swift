// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Analytics
import BackgroundTasks
import SharedPocketKit

public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    private let source: Source
    private let userDefaults: UserDefaults
    private let firstLaunchDefaults: UserDefaults
    private let refreshCoordinator: RefreshCoordinator
    private let appSession: AppSession
    internal let notificationService: PushNotificationService
    private let user: User

    convenience override init() {
        self.init(services: Services.shared)
    }

    init(services: Services) {
        self.source = services.source
        self.userDefaults = services.userDefaults
        self.firstLaunchDefaults = services.firstLaunchDefaults
        self.refreshCoordinator = services.refreshCoordinator
        self.appSession = services.appSession
        self.notificationService = services.notificationService
        self.user = services.user
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Log.start(dsn: Keys.shared.sentryDSN)

        if CommandLine.arguments.contains("clearKeychain") {
            appSession.currentSession = nil
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
            appSession: appSession,
            user: user,
            userDefaults: firstLaunchDefaults
        ).signOutOnFirstLaunch()

        if let guid = ProcessInfo.processInfo.environment["sessionGUID"],
           let accessToken = ProcessInfo.processInfo.environment["accessToken"],
           let userIdentifier = ProcessInfo.processInfo.environment["sessionUserID"] {
            appSession.currentSession = Session(
                guid: guid,
                accessToken: accessToken,
                userIdentifier: userIdentifier
            )
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.refreshCoordinator.initialize()
            self?.source.restore()
        }
        Textiles.initialize()

        return true
    }
}
