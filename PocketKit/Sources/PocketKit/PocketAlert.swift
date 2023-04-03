import UIKit
import Localization

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
            title: Localization.anErrorOccurred,
            message: error.localizedDescription,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.ok, style: .default) { _ in
                    handler()
                }
            ],
            preferredAction: nil
        )
    }
}
