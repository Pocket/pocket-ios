import UIKit
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
        let child: UIViewController

        let legacyUserMigration = LegacyUserMigration(
            userDefaults: userDefaults,
            encryptedStore: encryptedStore,
            appSession: appSession,
            groupID: Keys.shared.groupdId
        )

        do {
            let attempted = try legacyUserMigration.perform()
            if attempted {
                Log.breadcrumb(category: "launch", level: .info, message: "Legacy user migration required; running.")
                // Legacy cleanup
                LegacyCleanupService().cleanUp()
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
                    consumerKey: Keys.shared.pocketApiConsumerKey
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
