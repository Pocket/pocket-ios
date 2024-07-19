// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BackgroundTasks
import Sync
import UIKit
import Combine
import SharedPocketKit

enum BackgroundRequestType {
    /// Instructs us to create a Processing Request, we are allowed 10 different tasks of this type scheduled at a time
    case processing
    /// Instructs us to create a Refresh Request, we are allowed 1 of this type schdeduled at a time
    case refresh
}

protocol RefreshCoordinator: AnyObject {
    var notificationCenter: NotificationCenter { get }
    var taskScheduler: BGTaskSchedulerProtocol { get }
    var appSession: AppSession { get }
    var subscriptions: [AnyCancellable] { get set }
    var sessionSubscriptions: [AnyCancellable] { get set }

    /// The taskID to be resgistered with the system for this background task and identified in info.plist
    var taskID: String { get }

    /// Which type of BGTaskRequest to create at any time.
    var backgroundRequestType: BackgroundRequestType { get }

    /// The minimum time to wait before the request is allowed to be retried again.
    /// If this is nil, we will never background refresh this cooridnator.
    var refreshInterval: TimeInterval? { get }

    /// The base implementation of the refresh function, it is expected to call this from a subclass via super.refresh(completion: completion) if you want session checking.
    /// - Parameter completion: The callback to execute upon finishing data loading
    /// - Parameter isForced: Whether or not a user manaully triggered the refreshing
    func refresh(isForced: Bool, _ completion: @escaping () -> Void)
}

/// An Abstract extension  that can be used to implement background refreshing and implement some default logic like observing to login/logout and foregorund notifications.
extension RefreshCoordinator {
    /// Register the background task and start listening for events
    func initialize() {
        _ = taskScheduler.registerHandler(forTaskWithIdentifier: taskID, using: .global(qos: .background)) { task in
            self.handleBackgroundRefresh(task)
            self.submitRequest()
        }

        // Register for login notifications
        NotificationCenter.default.publisher(for: .userLoggedIn)
            .sink { [weak self] notification in
                self?.handleSession(session: notification.object as? SharedPocketKit.Session)
            }
            .store(in: &sessionSubscriptions)

        // Register for login notifications
        NotificationCenter.default.publisher(for: .anonymousLogin)
            .sink { [weak self] notification in
                self?.handleSession(session: notification.object as? SharedPocketKit.Session)
            }
            .store(in: &sessionSubscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(for: .userLoggedOut)
            .sink { [weak self] notification in
                self?.handleSession(session: nil)
            }
            .store(in: &sessionSubscriptions)

        // Because session could already be available at init, lets try and use it.
        handleSession(session: appSession.currentSession)
    }

    /// Handles a session if it exists.
    /// - Parameter session: The session we need to operate with
    func handleSession(session: SharedPocketKit.Session?) {
        guard let session = session else {
            // If the session is nil, ensure the user's view is logged out
            self.tearDownSession()
            return
        }

        // We have a session! Ensure the user is logged in.
        self.setUpSession(session)
    }

    /// Sets up the class with the logged in session
    /// - Parameter session: The session we are setting up
    private func setUpSession(_ session: SharedPocketKit.Session) {
        guard !session.isAnonymous || self is FeatureFlagsRefreshCoordinator || self is HomeRefreshCoordinator else {
            return
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
            self.refreshData {}
        }.store(in: &subscriptions)

        // The user just logged in, we need to refresh the latest data
        self.refreshData {}

        // The user just logged in, lets setup background refreshing
        self.submitRequest()
    }

    /// Unsubscribes all listeners and cancels any pending background tasks
    private func tearDownSession() {
        subscriptions = []
        taskScheduler.cancel(taskID)
    }

    /// Submit the request to be scheduled anytime after the given interval
    private func submitRequest() {
        guard let refreshInterval else {
            Log.info("No refresh interval set by developer, not scheduling a refresh for \(self.taskID)")
            return
        }

        guard appSession.currentSession != nil else {
            Log.warning("No user session, so not scheduling a refresh \(self.taskID)")
            return
        }

        #if targetEnvironment(simulator)
            // You can't submit background requests in the simulator, so stopping early.
            Log.info("Simulator - Not submitting background request for \(self.taskID)")
        #else
        do {
            let request: BGTaskRequest
            switch backgroundRequestType {
            case .processing:
                request = BGProcessingTaskRequest(identifier: taskID)
                (request as? BGProcessingTaskRequest)?.requiresNetworkConnectivity = true
            case .refresh:
                request = BGAppRefreshTaskRequest(identifier: taskID)
            }
            request.earliestBeginDate = Date().addingTimeInterval(refreshInterval)
            try taskScheduler.submit(request)
        } catch {
            Log.warning("Could not submit background task request for \(self.taskID)")
            Log.capture(error: error)
        }
        #endif
    }

    /// Private function that calls the underlying refresh function
    /// - Parameter completion: Completion to call when done refreshing data
    private func refreshData(_ completion: @escaping () -> Void) {
        guard appSession.currentSession != nil else {
            completion()
            return
        }
        self.refresh(isForced: false) {
            completion()
        }
    }

    /// Handle the launching of the background request we scheduled that is lauching
    /// - Parameter task: The task coming in from apple that we call when the task completes.
    private func handleBackgroundRefresh(_ task: BGTaskProtocol) {
        /// Tell the system that when the expiration handler is called that the task did not complete.
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Log.breadcrumb(category: "background", level: .debug, message: "Starting background refresh call for \(self.taskID)")

        /// Call the refresh function and then upon sucess set the task completed
        self.refreshData {
            task.setTaskCompleted(success: true)
        }
    }
}
