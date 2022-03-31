import UIKit
import Textile
import Apollo
import SharedPocketKit
import Sync


class MainViewController: UIViewController {
    private let childViewController: UIViewController

    convenience init() {
        Textiles.initialize()

        let appSession = AppSession()
        let child: UIViewController

        if appSession.currentSession == nil {
            child = LoggedOutViewController(
                viewModel: LoggedOutViewModel(
                    dismissTimer: Timer.TimerPublisher(interval: 2, runLoop: .main, mode: .default)
                )
            )
        } else {
            child = SavedItemViewController(
                viewModel: SavedItemViewModel(
                    appSession: appSession,
                    saveService: PocketSaveService(
                        sessionProvider: appSession,
                        consumerKey: Keys.shared.pocketApiConsumerKey,
                        expiringActivityPerformer: ProcessInfo.processInfo
                    ),
                    dismissTimer: Timer.TimerPublisher(interval: 2, runLoop: .main, mode: .default)
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
