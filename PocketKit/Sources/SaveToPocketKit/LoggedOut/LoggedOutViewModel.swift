import UIKit
import SharedPocketKit
import Combine


class LoggedOutViewModel {
    private let dismissTimer: Timer.TimerPublisher

    private var dismissTimerCancellable: AnyCancellable? = nil

    let infoViewModel = InfoView.Model(
        style: .error,
        attributedText: NSAttributedString(
            string: "Log in to Pocket to save",
            style: .mainTextError
        ),
        attributedDetailText: NSAttributedString(
            string: "Pocket couldn't save the link. Log in to the Pocket app and try saving again.",
            style: .detailText
        )
    )

    let dismissAttributedText = NSAttributedString(string: "Tap to Dismiss", style: .dismiss)

    @Published
    var actionButtonConfiguration: UIButton.Configuration? = nil

    init(dismissTimer: Timer.TimerPublisher) {
        self.dismissTimer = dismissTimer
    }

    func viewWillAppear(context: ExtensionContext?, origin: Any) {
        if responder(from: origin) != nil {
            var configuration: UIButton.Configuration = .filled()
            configuration.background.backgroundColor = UIColor(.ui.teal2)
            configuration.background.cornerRadius = 13
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0)
            configuration.attributedTitle = AttributedString(NSAttributedString(string: "Log in to Pocket", style: .logIn))
            actionButtonConfiguration = configuration
        }
    }

    func viewDidAppear(context: ExtensionContext?) {
        autodismiss(from: context)
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

    private func autodismiss(from context: ExtensionContext?) {
        dismissTimerCancellable = dismissTimer.autoconnect().first().sink(receiveCompletion:{ [weak self] _ in
            self?.finish(context: context)
        }, receiveValue: { _ in })
    }

    private func handleLoggedOut(context: ExtensionContext?, origin: Any) {
        logIn(from: context, origin: origin)
    }
}
