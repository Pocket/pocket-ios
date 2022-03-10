import UIKit

protocol BackgroundTaskManager {
    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension BackgroundTaskManager {
    func beginTask() -> UIBackgroundTaskIdentifier {
        beginTask(withName: nil, expirationHandler: nil)
    }
}

extension UIApplication: BackgroundTaskManager {
    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginBackgroundTask(withName: name, expirationHandler: expirationHandler)
    }

    func endTask(_ identifier: UIBackgroundTaskIdentifier) {
        endBackgroundTask(identifier)
    }
}
