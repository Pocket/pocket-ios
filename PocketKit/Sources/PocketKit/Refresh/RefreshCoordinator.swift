import BackgroundTasks
import Sync
import UIKit
import Combine


class RefreshCoordinator {
    static let taskID = "com.mozilla.pocket.next.refresh"

    private let notificationCenter: NotificationCenter
    private let taskScheduler: BGTaskSchedulerProtocol
    private let source: Source
    private let backgroundTaskManager: BackgroundTaskManager

    private var subscriptions: [AnyCancellable] = []

    init(
        notificationCenter: NotificationCenter,
        taskScheduler: BGTaskSchedulerProtocol,
        source: Source,
        backgroundTaskManager: BackgroundTaskManager
    ) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.source = source
        self.backgroundTaskManager = backgroundTaskManager
    }

    func initialize() {
        _ = taskScheduler.registerHandler(forTaskWithIdentifier: Self.taskID, using: .main) { [weak self] task in
            self?.refresh(task)
            self?.submitRequest()
        }

        notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification, object: nil).sink { [weak self] _ in
            self?.submitRequest()
        }.store(in: &subscriptions)
    }

    private func submitRequest() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: Self.taskID)
            try taskScheduler.submit(request)
        } catch {
            print(error)
        }
    }

    private func refresh(_ task: BGTaskProtocol) {
        let taskID = backgroundTaskManager.beginTask()

        task.expirationHandler = { [backgroundTaskManager] in
            task.setTaskCompleted(success: false)
            backgroundTaskManager.endTask(taskID)
        }

        source.refresh() { [backgroundTaskManager] in
            task.setTaskCompleted(success: true)
            backgroundTaskManager.endTask(taskID)
        }
    }
}
