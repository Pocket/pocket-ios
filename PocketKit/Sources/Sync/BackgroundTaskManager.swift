public protocol BackgroundTaskManager {
    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> Int
    func endTask(_ identifier: Int)
}

public extension BackgroundTaskManager {
    func beginTask() -> Int {
        beginTask(withName: nil, expirationHandler: nil)
    }
}
