import UIKit
import Combine
import AuthenticationServices


class LoggedOutCoordinator: NSObject {
    lazy var viewController: UIViewController = {
        LoggedOutViewController(viewModel: viewModel)
    }()

    private var viewModel: LoggedOutViewModel

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: LoggedOutViewModel) {
        self.viewModel = viewModel
        super.init()

        self.viewModel.contextProvider = self
        self.viewModel.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            guard let alert = alert else {
                return
            }
            self?.viewController.present(UIAlertController(alert), animated: true)
        }.store(in: &subscriptions)
    }
}

extension LoggedOutCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        viewController.view.window!
    }
}
