// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Analytics
import Textile
import Apollo
import SharedPocketKit
import Sync
import Adjust

class MainViewController: UIViewController {
    private let childViewController: UIViewController

    convenience init() {
        self.init(services: .shared)
    }

    convenience init(services: Services) {
        services.start {
            services.userDefaults.set(true, forKey: .forceRefreshFromExtension)
        }

        Textiles.initialize()

        let appSession = services.appSession
        let encryptedStore = PocketEncryptedStore()
        let userDefaults = services.userDefaults
        let user = services.user
        let notificationCenter = services.notificationCenter
        let child: UIViewController
        let tracker = services.tracker
        let braze = services.braze

        // Reset and attach at least an api user entity on extension launch
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])

        if let currentSession = appSession.currentSession {
            // Attach a user entity at launch if it exists
            tracker.addPersistentEntity(UserEntity(guid: currentSession.guid, userID: currentSession.userIdentifier, adjustAdId: Adjust.adid()))
        }

        SignOutOnFirstLaunch(
            appSession: appSession,
            user: user,
            userDefaults: userDefaults
        ).signOutOnFirstLaunch()

        let legacyUserMigration = LegacyUserMigration(
            userDefaults: userDefaults,
            encryptedStore: encryptedStore,
            appSession: appSession,
            groupID: Keys.shared.groupID
        )

        do {
            let attempted = try legacyUserMigration.attemptMigration {
                tracker.track(event: Events.Migration.MigrationTo_v8DidBegin(source: .saveToPocketKit))
                braze.signedInUserDidBeginMigration()
            }

            if attempted {
                // Migration ran successfully, so lets reset the entities to capture it.
                // We do a reset in case something else recieves a login notice first and to ensure no duplicates.
                if let currentSession = appSession.currentSession {
                    tracker.resetPersistentEntities([
                        APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey),
                        UserEntity(guid: currentSession.guid, userID: currentSession.userIdentifier, adjustAdId: Adjust.adid())
                    ])
                }
                tracker.track(event: Events.Migration.MigrationTo_v8DidSucceed(source: .saveToPocketKit))
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration required; running.")
                // Legacy cleanup
                LegacyCleanupService().cleanUp()
            } else {
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration not required; skipped.")
            }
        } catch LegacyUserMigrationError.emptyData {
            Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration has no data to decrypt, likely due to a fresh install of Pocket 8; skipping.")
            // Since there's no initial data, we don't have anything to migrate, and we can skip
            // any further attempts at running this migration. This is not a true "error" in the sense that
            // it breaks migration; it's a special case to be handled if data was created (on fresh install).
            legacyUserMigration.forceSkip()
        } catch LegacyUserMigrationError.noSession {
            // If a user was logged out in Pocket 7, and then launches Pocket 8, there is no session to migrate.
            // Previously, this would trigger a `failedDeserialization`, which is correct, but not within the context
            // of a valid user case. If there was nothing to migrate, we can skip any further attempts.
            Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration has no session to migration; skipping.")
            legacyUserMigration.forceSkip()
        } catch LegacyUserMigrationError.missingStore {
            tracker.track(event: Events.Migration.MigrationTo_v8DidFail(with: LegacyUserMigrationError.missingStore, source: .saveToPocketKit))
            Log.breadcrumb(category: "launch", level: .info, message: "No previous store for user migration; skipped.")
            // Since we don't have a store, we can skip any further attempts at running this migration.
            legacyUserMigration.forceSkip()
        } catch {
            // All errors are something we can't resolve client-side, so we don't want to re-attempt
            // on further launches.
            tracker.track(event: Events.Migration.MigrationTo_v8DidFail(with: error, source: .saveToPocketKit))
            legacyUserMigration.forceSkip()
            Log.capture(error: error)
        }

        // The session backup utility can be started after user migration since
        // the session can possibly already be backed up, i.e if used for user migration
        SessionBackupUtility(
            userDefaults: userDefaults,
            store: PocketEncryptedStore(),
            notificationCenter: notificationCenter
        ).start()

        if appSession.currentSession == nil {
            Log.clearUser()
            child = LoggedOutViewController(
                viewModel: LoggedOutViewModel()
            )
        } else {
            Log.setUserID(services.appSession.currentSession!.userIdentifier)
            child = SavedItemViewController(
                viewModel: SavedItemViewModel(
                    appSession: appSession,
                    saveService: services.saveService,
                    dismissTimer: Timer.TimerPublisher(interval: 60.0, runLoop: .main, mode: .default),
                    tracker: Services.shared.tracker.childTracker(hosting: .saveExtension.screen),
                    consumerKey: Keys.shared.pocketApiConsumerKey,
                    userDefaults: userDefaults,
                    user: Services.shared.user,
                    notificationCenter: notificationCenter
                )
            )
        }

        self.init(childViewController: child)
    }

    init(childViewController: UIViewController) {
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)

        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
