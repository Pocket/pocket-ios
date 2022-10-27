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
        let child: UIViewController

        if appSession.currentSession == nil {
            Crashlogger.clearUser()
            child = LoggedOutViewController(
                viewModel: LoggedOutViewModel()
            )
        } else {
            Crashlogger.setUserID(services.appSession.currentSession!.userIdentifier)
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
