import UIKit


class CompactAccountCoordinator {
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

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }
}
