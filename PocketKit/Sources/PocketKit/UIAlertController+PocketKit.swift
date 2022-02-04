import UIKit


extension UIAlertController {
    convenience init(_ alert: PocketAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: alert.preferredStyle)

        alert.actions.forEach(self.addAction)
        self.preferredAction = alert.preferredAction
    }
}
