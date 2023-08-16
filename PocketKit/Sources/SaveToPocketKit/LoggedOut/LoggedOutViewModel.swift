// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SharedPocketKit
import Combine
import Localization

class LoggedOutViewModel {
    let infoViewModel: InfoView.Model = .loggedOut

    let dismissAttributedText = NSAttributedString(
        string: Localization.SaveToPocket.tapToDismiss,
        style: .dismiss
    )

    @Published var actionButtonConfiguration: UIButton.Configuration?

    func viewWillAppear(context: ExtensionContext?, origin: Any) {
        if responder(from: origin) != nil {
            var configuration: UIButton.Configuration = .filled()
            configuration.background.backgroundColor = UIColor(.ui.teal2)
            configuration.background.cornerRadius = 13
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0)
            configuration.attributedTitle = AttributedString(NSAttributedString(string: "Log in to Pocket", style: .buttonText))
            actionButtonConfiguration = configuration
        }
    }

    func finish(context: ExtensionContext?, completionHandler: ((Bool) -> Void)? = nil) {
        context?.completeRequest(returningItems: nil, completionHandler: completionHandler)
    }

    func logIn(from context: ExtensionContext?, origin: Any) {
        guard let responder = responder(from: origin) else {
            return
        }

        finish(context: context) { [weak self] _ in
            self?.open(url: URL(string: "pocket-next:")!, using: responder)
        }
    }
}

extension LoggedOutViewModel {
    private func responder(from origin: Any) -> UIResponder? {
        guard let origin = origin as? UIResponder else {
            return nil
        }

        let selector = sel_registerName("openURL:")
        var responder: UIResponder? = origin
        while let r = responder, !r.responds(to: selector) {
            responder = r.next
        }

        return responder
    }

    private func open(url: URL, using responder: UIResponder) {
        let selector = sel_registerName("openURL:")
        responder.perform(selector, with: url)
    }

    private func handleLoggedOut(context: ExtensionContext?, origin: Any) {
        logIn(from: context, origin: origin)
    }
}
