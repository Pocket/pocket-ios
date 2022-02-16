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

        self.viewModel.events.sink { event in
            switch event {
            case .login(let token):
                print(token)
            case .error(let error):
                print(error.localizedDescription)
            }
        }.store(in: &subscriptions)
    }
}

extension LoggedOutCoordinator: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        viewController.view.window!
    }
}
