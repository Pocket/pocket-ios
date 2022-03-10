import UIKit
import Sync


extension UIApplication: BackgroundTaskManager {
    public func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> Int {
        beginBackgroundTask(withName: name, expirationHandler: expirationHandler).rawValue
    }

    public func endTask(_ identifier: Int) {
        endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: identifier))
    }
}
