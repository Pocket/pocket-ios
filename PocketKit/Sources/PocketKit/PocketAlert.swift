import UIKit

struct PocketAlert {
    let title: String?
    let message: String?
    let preferredStyle: UIAlertController.Style
    let actions: [UIAlertAction]
    let preferredAction: UIAlertAction?
}

extension PocketAlert {
    init(_ error: Error, handler: @escaping () -> Void) {
        self.init(
            title: L10n.anErrorOccurred,
            message: error.localizedDescription,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: L10n.ok, style: .default) { _ in
                    handler()
                }
            ],
            preferredAction: nil
        )
    }
}
