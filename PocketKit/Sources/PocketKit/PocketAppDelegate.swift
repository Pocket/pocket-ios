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
    static var phoneOrientationLock = UIInterfaceOrientationMask.portrait

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

        self.refreshCoordinator.initialize()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.source.restore()
        }
        Textiles.initialize()

        let legacyUserMigration = LegacyUserMigration(
            userDefaults: userDefaults,
            encryptedStore: PocketEncryptedStore(),
            appSession: appSession,
            groupID: Keys.shared.groupID
        )

        do {
            let attempted = try legacyUserMigration.perform()
            if attempted {
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration required; running.")
            } else {
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration not required; skipped.")
            }
        } catch LegacyUserMigrationError.missingStore {
            Log.breadcrumb(category: "launch", level: .info, message: "No previous store for user migration; skipped.")
            // Since we don't have a store, we can skip any further attempts at running this migration.
            legacyUserMigration.forceSkip()
        } catch {
            // All errors are something we can't resolve client-side, so we don't want to re-attempt
            // on further launches.
            legacyUserMigration.forceSkip()
            Log.capture(error: error)
        }

        let legacyUserMigration = LegacyUserMigration(
            userDefaults: userDefaults,
            encryptedStore: PocketEncryptedStore(),
            appSession: appSession
        )

        do {
            let attempted = try legacyUserMigration.perform()
            if attempted {
                Crashlogger.breadcrumb(category: "launch", level: .info, message: "Legacy user migration required; running.")
            } else {
                Crashlogger.breadcrumb(category: "launch", level: .info, message: "Legacy user migration not required; skipped.")
            }
        } catch LegacyUserMigrationError.missingStore {
            Crashlogger.breadcrumb(category: "launch", level: .info, message: "No previous store for user migration; skipped.")
            // Since we don't have a store, we can skip any further attempts at running this migration.
            legacyUserMigration.forceSkip()
        } catch {
            // All errors are something we can't resolve client-side, so we don't want to re-attempt
            // on further launches.
            legacyUserMigration.forceSkip()
            Crashlogger.capture(error: error)
        }

        return true
    }

    /// Sets orientations to use for the views
    /// - Parameters:
    ///   - application: singleton app object
    ///   - window: window whose interface orientations you want to retrieve
    /// - Returns: orientations to use for the view
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return .all }
        return PocketAppDelegate.phoneOrientationLock
    }
}
