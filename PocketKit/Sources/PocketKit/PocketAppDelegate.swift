// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Analytics
import BackgroundTasks
import SharedPocketKit
import Adjust

public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    static var phoneOrientationLock = UIInterfaceOrientationMask.portrait

    private let source: Source
    private let userDefaults: UserDefaults
    private let refreshCoordinators: [RefreshCoordinator]
    private let appSession: AppSession
    private let user: User
    private let brazeService: BrazeProtocol
    private let tracker: Tracker
    private let sessionBackupUtility: SessionBackupUtility

    let notificationService: PushNotificationService

    convenience override init() {
        self.init(services: Services.shared)
    }

    init(services: Services) {
        self.source = services.source
        self.userDefaults = services.userDefaults
        self.refreshCoordinators = services.refreshCoordinators
        self.appSession = services.appSession
        self.user = services.user
        self.brazeService = services.braze
        self.tracker = services.tracker
        self.sessionBackupUtility = services.sessionBackupUtility

        self.notificationService = services.notificationService
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Log.start(dsn: Keys.shared.sentryDSN)

        if CommandLine.arguments.contains("clearKeychain") {
            appSession.currentSession = nil
        }

        if CommandLine.arguments.contains("clearUserDefaults") {
            userDefaults.resetKeys()
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
            userDefaults: userDefaults
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

        self.refreshCoordinators.forEach({$0.initialize()})
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.source.restore()
        }
        Textiles.initialize()

        enableAdjust()

        migrateLegacyAccount()

        // The session backup utility can be started after user migration since
        // the session can possibly already be backed up, i.e if used for user migration
        sessionBackupUtility.start()

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

    /// Attempt to migrate a legacy (v7) account to v8
    func migrateLegacyAccount() {
        let legacyUserMigration = LegacyUserMigration(
            userDefaults: userDefaults,
            encryptedStore: PocketEncryptedStore(),
            appSession: appSession,
            groupID: Keys.shared.groupID
        )

        do {
            let attempted = try legacyUserMigration.attemptMigration(migrationWillBegin: { [weak self] in
                self?.tracker.track(event: Events.Migration.MigrationTo_v8DidBegin(source: .pocketKit))
                self?.brazeService.signedInUserDidBeginMigration()
            })

            if attempted {
                tracker.track(event: Events.Migration.MigrationTo_v8DidSucceed(source: .pocketKit))
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration required; running.")
                // Legacy cleanup
                LegacyCleanupService().cleanUp()
            } else {
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration not required; skipped.")
            }
        } catch LegacyUserMigrationError.emptyData {
            Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration has no data to decrypt, likely due to a fresh install of Pocket 8")
            // Since there's no initial data, we don't have anything to migrate, and we can skip
            // any further attempts at running this migration. This is not a true "error" in the sense that
            // it breaks migration; it's a special case to be handled if data was created (on fresh install).
            legacyUserMigration.forceSkip()
        } catch LegacyUserMigrationError.missingStore {
            tracker.track(event: Events.Migration.MigrationTo_v8DidFail(with: LegacyUserMigrationError.missingStore, source: .pocketKit))
            Log.breadcrumb(category: "launch", level: .info, message: "No previous store for user migration; skipped.")
            // Since we don't have a store, we can skip any further attempts at running this migration.
            legacyUserMigration.forceSkip()
        } catch {
            // All errors are something we can't resolve client-side, so we don't want to re-attempt
            // on further launches.
            tracker.track(event: Events.Migration.MigrationTo_v8DidFail(with: error, source: .pocketKit))
            legacyUserMigration.forceSkip()
            Log.capture(error: error)
        }
    }

    func enableAdjust() {
        let adjustAppToken = Keys.shared.adjustAppToken
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(
            appToken: adjustAppToken,
            environment: environment
        )
        Adjust.appDidLaunch(adjustConfig)
    }
}
