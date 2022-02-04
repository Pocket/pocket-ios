import UIKit


class CompactSettingsCoordinator {
    var viewController: UIViewController {
        navigationController
    }

    private let navigationController: UINavigationController
    private let settingsViewController: UIViewController
    private let model: SettingsViewModel

    init(model: SettingsViewModel) {
        self.model = model

        settingsViewController = SettingsViewController(model: model)
        navigationController = UINavigationController(rootViewController: settingsViewController)

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }
}
