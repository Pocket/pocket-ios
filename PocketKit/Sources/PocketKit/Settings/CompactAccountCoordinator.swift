import UIKit


class CompactAccountCoordinator: NSObject {
    var viewController: UIViewController {
        navigationController
    }

    private let navigationController: UINavigationController
    private let accountViewController: UIViewController
    private let model: AccountViewModel

    init(model: AccountViewModel) {
        self.model = model

        accountViewController = AccountViewController(model: model)
        navigationController = UINavigationController(rootViewController: accountViewController)

        super.init()

        navigationController.delegate = self
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }
}

extension CompactAccountCoordinator: UINavigationControllerDelegate {
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard navigationController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return navigationController.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
}
