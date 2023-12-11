// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Combine
import AuthenticationServices

class LoggedOutCoordinator: NSObject {
    lazy var viewController: LoggedOutViewController = {
        LoggedOutViewController(viewModel: viewModel)
    }()

    private var viewModel: LoggedOutViewModel

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: LoggedOutViewModel) {
        self.viewModel = viewModel
        super.init()

        self.viewModel.contextProvider = self
        self.viewModel.$presentedAlert.sink { [weak self] alert in
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
