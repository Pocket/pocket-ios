// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    /// Proxies to register(forTaskWithIdentifier: identifier, using: queue) within iOS
    /// - Parameter taskRequest: The task to submit to the operating system
    func submit(_ taskRequest: BGTaskRequest) throws

    /// Proxies to cancel(taskRequestWithIdentifier: identifier) within ios
    /// - Parameter identifier: Identifier of the task to cancel
    func cancel(_ identifier: String)
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

    func cancel(_ identifier: String) {
        cancel(taskRequestWithIdentifier: identifier)
    }
}
