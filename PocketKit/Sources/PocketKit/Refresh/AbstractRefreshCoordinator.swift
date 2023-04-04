// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BackgroundTasks
import Sync
import UIKit
import Combine

protocol AbstractRefreshCoordinatorProtocol {

    /// Register the background task and start listening for events
    func initialize()

    /// The base implementation of the refresh function, it is expected to call this from a subclass via super.refresh(completion: completion) if you want session checking.
    /// - Parameter completion: The callback to execute upon finishing data loading
    func refresh(completion: @escaping () -> Void)

    /// Handle the launching of the background request we scheduled that is lauching
    /// - Parameter task: The task coming in from apple that we call when the task completes.
    func handleBackgroundRefresh(_ task: BGTaskProtocol)
}

/// An Abstract class that can be used to implement background refreshing and implement some default logic like observing to login/logout and foregorund notifications.
class AbstractRefreshCoordinator: AbstractRefreshCoordinatorProtocol {

    /// The taskID to be resgistered with the system for this background task and identified in info.plist
    var taskID: String!

    /// The minimum time to wait before the request is allowed to be retried again.
    var refreshInterval: TimeInterval!

    private let notificationCenter: NotificationCenter
    private let taskScheduler: BGTaskSchedulerProtocol
    private let sessionProvider: SessionProvider

    private var subscriptions: [AnyCancellable] = []

    init(
        notificationCenter: NotificationCenter,
        taskScheduler: BGTaskSchedulerProtocol,
        sessionProvider: SessionProvider
    ) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.sessionProvider = sessionProvider
    }

    func initialize() {
        _ = taskScheduler.registerHandler(forTaskWithIdentifier: taskID, using: .global(qos: .background)) { [weak self] task in
            guard let self else {
                Log.captureNilWeakSelf()
                return
            }
            self.handleBackgroundRefresh(task)
            self.submitRequest()
        }

        notificationCenter.publisher(for: UIScene.didEnterBackgroundNotification, object: nil).sink { [weak self] _ in
            guard let self else {
                Log.captureNilWeakSelf()
                return
            }
            self.submitRequest()
        }.store(in: &subscriptions)

        notificationCenter.publisher(for: UIScene.willEnterForegroundNotification, object: nil).sink { [weak self] _ in
            guard let self else {
                Log.captureNilWeakSelf()
                return
            }
            self.refresh {}
        }.store(in: &subscriptions)

        // TODO: add in logout/login handling
    }

    internal func refresh(completion: @escaping () -> Void) {
        guard (sessionProvider.session) != nil else {
            Log.info("Not refreshing \(Self.Type.self) because no active session")
            return
        }
    }

    /// Submit the request to be scheduled anytime after the given interval
    private func submitRequest() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: taskID)
            request.earliestBeginDate = Date().addingTimeInterval(refreshInterval)
            try taskScheduler.submit(request)
        } catch {
            Log.capture(error: error)
        }
    }

    internal func handleBackgroundRefresh(_ task: BGTaskProtocol) {
        /// Tell the system that when the expiration handler is called that the task did not complete.
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        /// Call the refresh function and then upon sucess set the task completed
        self.refresh {
            task.setTaskCompleted(success: true)
        }
    }
}
