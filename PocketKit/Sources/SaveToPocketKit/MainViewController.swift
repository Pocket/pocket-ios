import UIKit
import Analytics
import Textile
import Apollo
import SharedPocketKit
import Sync

class MainViewController: UIViewController {
    private let childViewController: UIViewController

    convenience init() {
        self.init(services: .shared)
    }

    convenience init(services: Services) {
        Textiles.initialize()

        let appSession = services.appSession
        let encryptedStore = PocketEncryptedStore()
        let userDefaults = services.userDefaults
        let user = services.user
        let notificationCenter = services.notificationCenter
        let child: UIViewController
        let tracker = services.tracker

        SignOutOnFirstLaunch(
            appSession: appSession,
            user: user,
            userDefaults: userDefaults
        ).signOutOnFirstLaunch()

        let legacyUserMigration = LegacyUserMigration(
            userDefaults: userDefaults,
            encryptedStore: encryptedStore,
            appSession: appSession,
            groupID: Keys.shared.groupdId
        )

        do {
            tracker.track(event: Events.Migration.MigrationTo_v8DidBegin(source: .saveToPocketKit))
            let attempted = try legacyUserMigration.attemptMigration { }
            if attempted {
                tracker.track(event: Events.Migration.MigrationTo_v8DidSucceed(source: .saveToPocketKit))
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration required; running.")
                // Legacy cleanup
                LegacyCleanupService().cleanUp()
            } else {
                tracker.track(event: Events.Migration.MigrationTo_v8DidFail(with: nil, source: .saveToPocketKit))
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration not required; skipped.")
            }
        } catch LegacyUserMigrationError.emptyData {
            Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration has no data to decrypt, likely due to a fresh install of Pocket 8; skipping.")
            // Since there's no initial data, we don't have anything to migrate, and we can skip
            // any further attempts at running this migration. This is not a true "error" in the sense that
            // it breaks migration; it's a special case to be handled if data was created (on fresh install).
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
                    dismissTimer: Timer.TimerPublisher(interval: 3.0, runLoop: .main, mode: .default),
                    tracker: Services.shared.tracker.childTracker(hosting: .saveExtension.screen),
                    consumerKey: Keys.shared.pocketApiConsumerKey,
                    userDefaults: userDefaults,
                    user: Services.shared.user
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
