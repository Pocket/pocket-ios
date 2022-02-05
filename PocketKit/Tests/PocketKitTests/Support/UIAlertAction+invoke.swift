import UIKit


extension UIAlertAction {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func invoke() {
        // sadly the handler is not exposed publicly
        // so we have to do some trickery to access it
        value(forKey: "handler")
            .flatMap { unsafeBitCast($0 as AnyObject, to: AlertHandler.self) }?(self)
    }
}
