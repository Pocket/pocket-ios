import BackgroundTasks


protocol BGTaskProtocol: AnyObject {
    var expirationHandler: (() -> Void)? { get set }

    func setTaskCompleted(success: Bool)
}

protocol BGTaskSchedulerProtocol {
    func registerHandler(
        forTaskWithIdentifier identifier: String,
        using queue: DispatchQueue?,
        launchHandler: @escaping (BGTaskProtocol) -> Void
    ) -> Bool

    func submit(_ taskRequest: BGTaskRequest) throws
}

// MARK: - BackgroundTasks Extensions
extension BGTask: BGTaskProtocol { }

extension BGTaskScheduler: BGTaskSchedulerProtocol {
    func registerHandler(
        forTaskWithIdentifier identifier: String,
        using queue: DispatchQueue?,
        launchHandler: @escaping (BGTaskProtocol) -> Void
    ) -> Bool {
        register(forTaskWithIdentifier: identifier, using: queue) { task in
            launchHandler(task)
        }
    }
}
